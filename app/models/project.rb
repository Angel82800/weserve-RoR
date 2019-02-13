class Project < ActiveRecord::Base
  extend FriendlyId

  include Discussable
  include Searchable
  include MediawikiConnection
  include AASM

  default_scope -> { order('projects.created_at DESC') }

  SHORT_DESCRIPTION_LIMIT = 250
  PROJECT_PAGE_SHORT_DESCRIPTION_LIMIT = 500

  attr_accessor :discussed_description, :crop_x, :crop_y, :crop_w, :crop_h

  # -------------------
  # Relations
  # -------------------
  has_many :boards, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :wikis, dependent: :destroy
  has_many :project_comments, dependent: :destroy
  has_many :project_edits, dependent: :destroy
  has_many :proj_admins, dependent: :destroy
  has_many :chatrooms, dependent: :destroy
  has_many :project_rates
  has_many :project_users
  has_many :section_details, dependent: :destroy
  has_many :followers, through: :project_users, class_name: 'User', source: :follower, dependent: :destroy
  has_many :coordinators, through: :project_users, class_name: 'User', source: :coordinator, dependent: :destroy
  has_many :lead_editors, through: :project_users, class_name: 'User', source: :lead_editor, dependent: :destroy
  has_one  :team, dependent: :destroy
  has_many :team_memberships, through: :team
  has_many :team_members, through: :team
  has_many :change_leader_invitations
  has_many :apply_requests, dependent: :destroy
  has_many :children, class_name: 'Project', foreign_key: 'parent_id', dependent: :nullify
  has_many :badges, dependent: :destroy

  belongs_to :user
  belongs_to :parent, class_name: 'Project', foreign_key: 'parent_id'

  # -------------------
  # Validates
  # -------------------
  validates :title, presence: true, length: {minimum: 3, maximum: 60},
            uniqueness: {case_sensitive: false}
  validates :slug, presence: true, uniqueness: true
  validates :wiki_page_name, presence: true, uniqueness: true
  validates :short_description, presence: true, length: {minimum: 3, maximum: SHORT_DESCRIPTION_LIMIT, message: :bad_short_description}
  # -------------------

  accepts_nested_attributes_for :section_details, allow_destroy: true, reject_if: ->(attributes) { attributes['project_id'].blank? && attributes['parent_id'].blank? }
  accepts_nested_attributes_for :project_edits, :reject_if => :all_blank, :allow_destroy => true

  # Define better that the association user is referring to the leader of the project
  alias_method :leader, :user

  acts_as_paranoid

  paginates_per 9

  mount_uploader :picture, PictureUploader
  crop_uploaded :picture

  # Friendly Id
  friendly_id :title, use: [:slugged, :finders]

  # this callback should be here
  after_restore :unarchive

  aasm column: 'state', whiny_transitions: false do
    state :pending
    state :accepted
    state :rejected

    event :accept do
      transitions :from => :pending, :to => :accepted
    end

    event :reject do
      transitions :from => :pending, :to => :rejected
    end
  end

  # Scope not_hidden
  scope :not_hidden, -> { where(hidden: false) }

  # -------------------
  # Class methods
  # -------------------
  def self.sent_mail_after_charge(task: task_obj, user: user_obj, cent_amount: cent_amount_value)
    task.interested_users.each do |usr|
      PaymentMailer.fund_task(
        payer: user,
        task: task,
        receiver: usr,
        amount: cent_amount
      ).deliver_later

      # reload to make sure you get the latest fund
      task.reload
      PaymentMailer.fully_funded_task(
        task: task,
        receiver: usr
      ).deliver_later if task.fully_funded?
    end
  end

  def self.fulltext_search(free_text, limit = 10)
    common_fulltext_search(
      %i(title description short_description full_description), free_text, limit
    )
  end

  # -------------------
  # Instance methods
  # -------------------
  def boards_sort_by_priority
    boards.sort_by { |obj| obj.priority.to_i }
  end

  def boards_max_priority
    boards_sort_by_priority.last.priority
  end

  def project_donors
    badges.where(badge_type: 0).map { |badge| badge.user }
  end

  def interested_users
    ((team_members + [leader]).uniq & followers)
  end

  def video_url
    video_id ||= "H30roqZiHRQ"
    "https://www.youtube.com/embed/#{video_id}"
  end

  def country_name
    country = ISO3166::Country[country_code]
    country.translations[I18n.locale.to_s] || country.name
  end

  def needed_budget
    tasks.where.not(state: "suggested_task").sum(:budget)
  end

  def funded_budget
    tasks.map(&:balance).compact.map(&:funded).inject(0, &:+)
  end

  def funded_percentages
    needed_budget == 0 ? "-" : ((funded_budget.to_f / needed_budget.to_f) * 100).round(2).to_s + "%"
  end

  def accepted_tasks
    tasks.where(state: 'accepted')
  end

  def reviewing_tasks
    tasks.where(state: 'reviewing')
  end

  def completed_tasks
    tasks.where(state: 'completed')
  end

  def to_dos_tasks
    tasks.where.not(state: ['suggested_task','completed'])
  end

  def tasks_relations_string
    "#{completed_tasks.count} / #{tasks.count}"
  end

  def tasks_to_review_relations_string
    "#{reviewing_tasks.count} / #{tasks.count}"
  end

  def team_relations_string
    if team.nil?
      return tasks.sum(:number_of_participants).to_s + " / " + tasks.sum(:target_number_of_participants).to_s
    else
      return team_memberships_count.to_s + " / " + tasks.sum(:target_number_of_participants).to_s
    end
    # self.team.team_memberships.count.to_s
    #tasks.sum(:number_of_participants).to_s + " / " + tasks.sum(:target_number_of_participants).to_s
  end

  def team_memberships_count
    if self.team.present?
      self.team.team_members.uniq.count
    else
      0
    end
  end

  def all_team_memberships_except(user)
    self.team_memberships.joins(:team_member).where.not(team_member: user).order('users.username ASC')
  end

  # unique team members with the Leader at the start of the list
  def uniq_team_members
    (team_members-[leader]).unshift(leader).uniq
  end

  def get_project_chatroom
    self.chatrooms.where(chatroom_type: 1).first
  end

  def rate_avg
    project_rates.average(:rate).to_i
  end

  def can_update?
    User.current_user.is_admin_for?(self)
  end

  def section_details_list parent = nil
    result = []
    section_details.of_parent(parent).ordered.each do |child|
      result << child
      result += section_details_list(child) if child.childs.exists?
    end
    result
  end

  def discussed_description= value
    if can_update?
      self.send(:write_attribute, 'description', value)
    else
      unless value == self.description.to_s
        Discussion.find_or_initialize_by(discussable: self, user_id: User.current_user.id, field_name: 'description').update_attributes(context: value)
      end
    end
  end

  def discussed_description
    can_update? ?
        self.send(:read_attribute, 'description') :
        discussions.of_field('description').of_user(User.current_user).last.try(:description) || self.send(:read_attribute, 'description')
  end

  def pending_change_leader?(user)
    project.change_leader_invitations.pending.where(user.email).count > 0
  end

  def follow!(user)
    self.project_users.create(user_id: user.id)
    NotificationsService.notify_about_follow_project(self, user)
  end

  def unfollow!(user)
    self.project_users.where(user_id: user.id).destroy_all
  end

  def is_approval_enabled?
    self.is_approval_enabled
  end

  def hide!
    self.hidden = true
    self.save
  end

  def un_hide!
    self.hidden = false
    self.save
  end

  def add_team_member(user)
    return if team_members.include? user
    team.team_memberships << TeamMembership.new(
      team: team, team_member: user, role: TeamMembership::TEAM_MATE_ID
    )
  end

  def wiki_page_name_from_title(title = nil)
    title ||= self.title
    self.wiki_page_name = title.tr('&#[]{}<>', ' ').strip
  end

  def picture_style
    if picture.present?
      'background: linear-gradient(rgba(0,0,0,0.75), rgba(0,0,0,0.25) 20%, '\
                  'transparent 50%, transparent 80%, rgba(0, 0, 0, 0.5)), '\
                  "url(#{picture.url}) no-repeat center center"
    end
  end

  def boards
    super.tap do |bs|
      bs << Board.default_with_tasks(tasks) if bs.empty?
    end
  end

  def project_coordinators
    coordinator_ids = team_memberships.where(role: TeamMembership::COORDINATOR_ID).pluck(:team_member_id)
    User.where(id: coordinator_ids)
  end

  def project_leader_and_coordinators
    (project_coordinators + [leader]).uniq
  end

  def notifiable_leader_and_coordinators
    (project_coordinators + [leader]).uniq & followers
  end
end
