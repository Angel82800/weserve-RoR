class Task < ActiveRecord::Base
  include AASM
  include Searchable
  include SendNotification

  default_scope -> { order('created_at DESC') }

  MINIMUM_FUND_BUDGET = 2_000   # cents
  MINIMUM_DONATION_SIZE = 2_000 # cents
  FUNDING_SOURCING = %(accepted incomplete)

  # -------------------
  # Relations
  # -------------------
  belongs_to :project
  belongs_to :user
  belongs_to :board
  has_one :task_review, dependent: :destroy
  has_many :task_comments, dependent: :delete_all
  has_many :assignments, dependent: :delete_all
  has_many :do_requests, dependent: :delete_all
  has_many :task_attachments, dependent: :delete_all
  has_many :team_memberships, through: :task_members, dependent: :destroy
  has_many :task_members
  has_many :transaction_histories, as: :tran_record
  has_many :source_transaction_histories, as: :source, class_name: 'TransactionHistory'
  has_many :payment_transactions
  has_one :balance
  has_many :approve_changes_tasks, dependent: :destroy

  # -------------------
  # Validates
  # -------------------
  validates :title, presence: true
  validates :condition_of_execution, presence: true
  validates :proof_of_execution, presence: true
  validates :budget, presence: true, numericality: { greater_than_or_equal_to: MINIMUM_FUND_BUDGET }, unless: :free?
  validates :deadline, presence: true
  validates :number_of_participants, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :target_number_of_participants, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  # -------------------

  before_create :assign_priority
  after_create :create_balance

  acts_as_paranoid

  mount_uploader :fileone, PictureUploader
  mount_uploader :filetwo, PictureUploader
  mount_uploader :filethree, PictureUploader
  mount_uploader :filefour, PictureUploader
  mount_uploader :filefive, PictureUploader

  aasm :column => 'state', :whiny_transitions => false do
    state :suggested_task
    state :accepted
    state :rejected
    state :doing
    state :reviewing
    state :completed
    state :incompleted

    event :reject_to_suggested do
      transitions :from => [:accepted, :incompleted], :to => :suggested_task
    end

    event :accept do
      transitions :from => [:suggested_task], :to => :doing, :guard => :fully_funded_and_enough_teammembers?
      transitions :from => [:suggested_task], :to => :accepted
    end

    event :reject do
      transitions :from => [:accepted, :suggested_task], :to => :rejected
    end

    event :start_doing do
      transitions :from => [:accepted, :incompleted], :to => :doing
    end

    event :begin_review do
      transitions :from => [:doing], :to => :reviewing
    end

    event :back_doing do
      transitions :from => [:reviewing], :to => :doing
    end

    event :back_funding do
      transitions :from => [:doing, :reviewing], :to => :accepted
    end

    event :incomplete do
      transitions :from => [:doing, :reviewing], :to => :accepted
    end

    event :complete do
      transitions :from => [:doing, :reviewing], :to => :completed
    end
  end

  scope :funding_sourcings, -> {where("state IN (?)", FUNDING_SOURCING)}

  # -------------------
  # Class methods
  # -------------------
  def self.fulltext_search(free_text, limit = 10)
    common_fulltext_search(
      %i(title description short_description condition_of_execution), free_text,
      limit
    )
  end

  # -------------------
  # Instance methods
  # -------------------
  def not_fully_funded_or_less_teammembers?
    !fully_funded? || !enough_teammembers?
  end

  def fully_funded_and_enough_teammembers?
    fully_funded? && enough_teammembers?
  end

  def enough_teammembers?
    number_of_participants >= target_number_of_participants
  end

  def fully_funded?
    free? || current_fund >= budget
  end

  def full_approve?
    approve_changes_tasks.length == approve_changes_tasks.where(approve: true).length
  end

  def suggested_or_accepted_task?
    suggested_task? || accepted?
  end

  # Returns an estimation in Satoshi how many each participant is going to recieve
  #
  # Method calculates estimation using planned +satoshi_budget+ and planned
  # +target_number_of_participants+
  #
  # Returned value can't be used to calculate real transfer amounts because
  # real +current_fund+ and `team_memberships.size` need to be used to precise
  # calculations
  def planned_amount_per_member
    return 0 if free?
    we_serve_part = budget * Payments::Base::Base.weserve_fee

    (budget - we_serve_part) / target_number_of_participants
  end

  def activities
    # We can do one query, but I think it will be harder to understand
    task_activities = Activity.where(targetable_id: self.id, targetable_type: 'Task')
    task_comments_activities = Activity.where(targetable_id: task_comments.ids, targetable_type: 'TaskComment')
    remove_task_assignee_activities = Activity.where(targetable_id: team_memberships.only_deleted.ids, targetable_type: 'TeamMembership')

    Activity.where(id: (task_activities.ids + task_comments_activities.ids + remove_task_assignee_activities.ids))
  end

  def current_fund
    balance ? balance.funded : 0.0
  end

  def current_amount
    balance ? balance.amount : 0.0
  end

  def update_current_fund!(funded = 0, amount = 0)
    return false unless balance
    balance.update_attributes(funded: funded, amount: amount)
  end

  def increment_fund(fund = 0)
    balance.increment!(:funded, fund)
  end

  def increment_amount(amount = 0)
    balance.increment!(:amount, amount)
  end

  def funded_percentage
    division = current_fund / budget
    division = 0 if division.nan?
    100 * division
  end

  def funded
    (budget == 0 || free?) ? "100%" : (( current_fund.to_f / budget.to_f) * 100).round.to_s + "%"
  end

  def funds_needed_to_fulfill_budget
    return 0 if completed?
    return 0 if free?

    delta = current_fund - budget
    delta > 0 ? 0 : delta.abs
  end

  def any_fundings?
    current_fund > 0
  end

  def not_any_funding?
    !any_fundings?
  end

  def current_fund_of_task
    current_fund.round.to_s
  end

  def team_relations_string
    number_of_participants.to_s + "/" + target_number_of_participants.to_s
  end

  def interested_users
    ((project.notifiable_leader_and_coordinators) + User.where(id: assignees_user_ids)).uniq
  end

  def assignees_ids
    assignments.accepted.map(&:id)
  end

  def assignees_user_ids
    assignments.where(state: %w(accepted completed)).map(&:user_id)
  end

  def is_leader(user_id)
    users = team_memberships.where(role: 1).collect(&:team_member_id)
    (users.include? user_id) ? true : false
  end

  def is_executer(user_id)
    users = self.project.team.team_memberships.where(role: 3 ).collect(&:team_member_id)
    (users.include? user_id) ? true : false
  end

  def is_team_member( user_id )
    users = self.project.team.team_memberships.collect(&:team_member_id)
    (users.include? user_id) ? true : false
  end


  def boards_for_select
    project.boards.collect { |p| [p.title, p.id] }
  end

  def create_balance
    build_balance.save
  end

  def is_funding?
    state.in? %w(accepted incompleted)
  end

  def in_progress?
    ['suggested_task','accepted'].exclude?(state)
  end

  def members_assign
    membership_ids = team_memberships.pluck(:team_member_id)
    project.team_members.where.not(id: membership_ids).uniq
  end

  private

  def assign_priority
    return self.priority = 1 unless self.project
    tasks =
      case self.state
      when *FUNDING_SOURCING
        self.project.tasks.funding_sourcings
      else
        self.project.tasks.send(self.state)
      end
    self.priority = tasks ? tasks.maximum(:priority).to_i + 1 : 1
  end
end
