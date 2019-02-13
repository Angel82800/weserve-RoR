module ActiveModel
  module Validations
    class ConfirmationValidator < EachValidator # :nodoc:
      def validate_each(record, attribute, value)
        if (confirmed = record.send("#{attribute}_confirmation")) && (value != confirmed)
          human_attribute_name = record.class.human_attribute_name(attribute)
          record.errors.add(:"#{attribute}_confirmation", :confirmation, options.merge(attribute: human_attribute_name))
          record.errors["#{attribute} confirmation"] << record.errors.messages[:"#{attribute}_confirmation"]
          record.errors.messages.delete(:password_confirmation)
        end
      end
    end
  end
end
class User < ActiveRecord::Base
  include Searchable

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  enum role: [:user, :vip, :admin, :manager, :moderator]

  # -------------------
  # Relations
  # -------------------
  has_one :tax_deduction, dependent: :destroy
  has_one :task_review, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :project_edits, dependent: :destroy
  has_many :project_comments, dependent: :delete_all
  has_many :activities, dependent: :delete_all
  has_many :do_requests, dependent: :delete_all
  has_many :do_for_frees
  has_many :assignments, dependent: :delete_all
  has_many :proj_admins, dependent: :delete_all

  has_many :payout_transactions, dependent: :destroy
  has_many :groupmembers, dependent: :destroy
  has_many :chatrooms, through: :groupmembers, dependent: :destroy
  has_many :user_message_read_flags, dependent: :destroy
  # users can send each other profile comments
  has_many :profile_comments, foreign_key: "receiver_id", dependent: :destroy
  has_many :project_rates
  has_many :team_memberships, foreign_key: "team_member_id"
  has_many :teams, :through => :team_memberships
  has_many :conversations, foreign_key: "sender_id"
  has_many :project_users
  has_many :followed_projects, through: :project_users, class_name: 'Project', source: :project
  has_many :discussions, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :admin_requests, dependent: :destroy
  has_many :apply_requests, dependent: :destroy
  has_many :transaction_histories, as: :tran_record
  has_many :source_transaction_histories, as: :source, class_name: 'TransactionHistory'
  has_many :payment_transactions, dependent: :destroy
  has_one :balance, dependent: :destroy
  has_one :payout_detail, dependent: :destroy
  has_one :custom_account, dependent: :destroy
  has_one :bank, dependent: :destroy
  has_one :credit_card, dependent: :destroy
  has_many :hold_balances, dependent: :delete_all
  has_many :badges, dependent: :destroy
  has_many :group_messages, dependent: :destroy

  # -------------------
  # Validates
  # -------------------
  validate :validate_username_unchange
  validates :username, presence: true, uniqueness: true
  validates :phone_number, length: { minimum: 5, maximum: 15 }, allow_blank: true
  validates_format_of :phone_number, with: /\A\+?[0-9]*\z/

  # Ref: https://github.com/plataformatec/devise/blob/88724e10adaf9ffd1d8dbfbaadda2b9d40de756a/lib/devise/models/validatable.rb
  # Validate everything as using `devise :validatable`
  # Except for validates_length_of password which is done only if no errors on password_confirmation were found
  validates :email, presence: true, if: :email_required?
  validates :email, uniqueness: true, allow_blank: true, if: :email_changed?
  validates_format_of :email, with: VALID_EMAIL_REGEX, allow_blank: true, if: :email_changed?
  validates :password, presence: true, if: :password_required?
  validates_confirmation_of :password, format: { message: "doesn't match" }, if: :password_required?
  # Override
  validates_length_of :password, within: Devise.password_length, allow_blank: true, if: ->(user) { user.errors[:password_confirmation].blank? }

  # -------------------
  # Callbacks
  # -------------------
  after_initialize :set_default_role, :if => :new_record?
  #after_create :populate_guid_and_token
  after_create :create_balance
  # -------------------

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :omniauthable, :confirmable

  mount_uploader :picture, PictureUploader
  crop_uploaded :picture

  mount_uploader :background_picture, PictureUploader
  crop_uploaded :background_picture

  delegate :acc_id, :to => :custom_account, :allow_nil => true

  # -------------------
  # Scopes
  # -------------------
  scope :name_like, -> (display_name) { where("username ILIKE ? OR CONCAT(first_name, ' ', last_name) ILIKE ?", "%#{display_name}%", "%#{display_name}%")}
  scope :not_hidden, -> { where(hidden: false) }

  # -------------------
  # Class methods
  # -------------------
  # set/get user
  def self.current_user=(usr)
    Thread.current[:current_user] = usr
  end

  def self.current_user
    Thread.current[:current_user]
  end

  def self.find_for_facebook_oauth(auth)
    registered_user = User.find_by(provider: auth.provider, uid: auth.uid)
    registered_user ||= User.find_by(email: auth.info.email)
    # return user if user.present?

    if registered_user
      registered_user.assign_attributes(
        provider: auth.provider,
        uid: auth.uid,
        first_name: get_first_name(auth),
        last_name: auth.info.last_name,
        facebook_url: auth.extra.link,
        username: "#{auth.info.name}#{auth.uid}"
      )

      registered_user.remote_picture_url = auth.info.image.gsub('http://', 'https://') unless registered_user.picture?

      registered_user.save
      return registered_user
    else
      user = User.create(
        provider: auth.provider,
        uid: auth.uid,
        first_name: get_first_name(auth),
        last_name: auth.info.last_name,
        email: auth.info.email || '',
        confirmed_at: DateTime.now,
        password: Devise.friendly_token[0, 20],
        facebook_url: auth.extra.link,
        username: "#{auth.info.name}#{auth.uid}",
        remote_picture_url: auth.info.image.gsub('http://', 'https://')
      )
      return user
    end
  end

  def self.find_for_twitter_oauth(auth)
    registered_user = User.find_by(provider: auth.provider, uid: auth.uid)
    registered_user ||= auth.info.email ? User.find_by(email: auth.info.email) : nil

    if registered_user
      registered_user.assign_attributes(
        provider: auth.provider,
        uid: auth.uid,
        first_name: get_first_name(auth),
        last_name: auth.info.last_name,
        twitter_url: auth.info.urls.Twitter,
        username: "#{auth.info.name}#{auth.uid}"
      )

      registered_user.remote_picture_url = auth.info.image.gsub('http://', 'https://') unless registered_user.picture?
      registered_user.description = auth.info.description unless registered_user.description?
      registered_user.country = auth.info.location unless registered_user.country?

      registered_user.save
      return registered_user
    else
      user = User.create(
        provider: auth.provider,
        uid: auth.uid,
        first_name: get_first_name(auth),
        last_name: auth.info.last_name,
        password: Devise.friendly_token[0, 20],
        confirmed_at: DateTime.now,
        description: auth.info.description,
        country: auth.info.location,
        twitter_url: auth.info.urls.Twitter,
        username: "#{auth.info.name}#{auth.uid}",
        remote_picture_url: auth.info.image.gsub('http://', 'https://')
      )
      return user
    end
  end

  def self.find_for_google_oauth2(access_token)
    registered_user = User.find_by(provider: access_token.provider, uid: access_token.uid)
    data = access_token.info
    registered_user ||= User.find_by(email: data['email'])

    if registered_user
      registered_user.assign_attributes(
        provider: access_token.provider,
        uid: access_token.uid,
        first_name: get_first_name(access_token),
        last_name: access_token.info.last_name,
        username: "#{access_token.info.name}#{access_token.uid}",
        company: access_token.extra.raw_info.hd
      )

      registered_user.company = access_token.extra.raw_info.hd unless registered_user.company?
      registered_user.remote_picture_url = access_token.info.image.gsub('http://', 'https://') unless registered_user.picture?

      registered_user.save
      return registered_user
    else
      user = User.create(
        provider: access_token.provider,
        email: data['email'],
        uid: access_token.uid,
        first_name: get_first_name(access_token),
        last_name: access_token.info.last_name,
        confirmed_at: DateTime.now,
        password: Devise.friendly_token[0, 20],
        company: access_token.extra.raw_info.hd,
        username: "#{access_token.info.name}#{access_token.uid}",
        remote_picture_url: access_token.info.image.gsub('http://', 'https://')
      )
      return user
    end
  end

  # -------------------
  # Instance methods
  # -------------------
  def set_default_role
    self.role ||= :user
  end

  def funded_projects_count
    payment_transactions.joins(:task).pluck('tasks.project_id').uniq.count
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def increment_amount(amount = 0)
    balance.increment!(:amount, amount.to_i)
  end

  def current_balance
    balance ? balance.amount : 0.0
  end

  def create_activity(item, action)
    activity = activities.new
    activity.targetable = item
    activity.action = action
    activity.save
    activity
  end

  def assign(taskItem, booleanFree)
    assignment = assignments.new
    assignment.task = taskItem
    assignment.project_id= assignment.task.project_id
    assignment.free = booleanFree
    assignment.save
    assignment.accept!
    assignment
  end

  def location
    [city, country].compact.join(' / ')
  end

  def get_users_projects_and_team_projects
    (projects + teams.includes(:project).collect(&:project)).uniq
  end

  def projects_team_memberships
    TeamMembership.where(id: TeamMembership.select(
      'max(team_memberships.id) as id'
    ).joins(:team).where(
      teams: { project_id: get_users_projects_and_team_projects }
    ).where.not(team_member_id: id).group(:team_member_id))
  end

  def all_dm_chatroom_users
    chatroom_ids = self.chatrooms.where(chatroom_type: 3).pluck(:id)
    Groupmember.where(chatroom_id: chatroom_ids).where.not(user_id: self.id).collect(&:user).uniq.sort_by(&:username)
  end

  def dm_chatroom_id_shared_with(user)
    (self.chatrooms.dm_chatrooms.pluck(:id) & user.chatrooms.where(chatroom_type: 3).pluck(:id)).first
  end

  def number_of_unread_messages
    self.user_message_read_flags.unread.count
  end

  # Method reports whether current user is an admin of the given project
  #
  # User is considered as an admin in project in any of these two cases:
  #
  #   * user is a creator of the project
  #   * user is invited admin of the project
  #
  # Returns boolean value
  def is_admin_for?(project)
    project.user_id == id || proj_admins.accepted.exists?(project_id: project.id)
  end

  def self.get_first_name(auth)
    auth.info.first_name.present? ? auth.info.first_name : auth.info.name
  end

  # Method reports whether current user is a project leader in the given project
  #
  # Returns boolean value
  def is_project_leader?(project)
    project.user.id == self.id
  end

  # Method reports whether current user is a coordinator in the given project
  #
  # Returns boolean value
  def is_coordinator_for?(project)
    project.team_memberships.exists?(
      team_member_id: id,
      role: TeamMembership::COORDINATOR_ID
    )
  end

  # Method reports whether current user is either:
  #
  #  * project leader
  #  * coordinator
  #
  # (any of the following) in the given project
  #
  # Returns boolean value
  def is_project_leader_or_coordinator?(project)
    is_project_leader?(project) || is_coordinator_for?(project)
  end

  def is_project_leader_or_admin?(project)
    is_project_leader?(project) || self.admin?
  end
    
  def is_project_leader_or_coordinator_or_admin?(project)
    is_project_leader_or_coordinator?(project) || self.admin?
  end

  # Method reports whether current user is a lead editor in the given project
  #
  # Returns boolean value
  def is_lead_editor_for?(project)
    project.team_memberships.exists?(
      team_member_id: id,
      role: TeamMembership::LEAD_EDITOR_ID
    )
  end

  # Method reports whether current user is a teammate in the given project
  #
  # Returns boolean value
  def is_teammate_for?(project)
    project.team_memberships.exists?(
      team_member_id: id,
      role: TeamMembership::TEAM_MATE_ID
    )
  end

  # Method reports whether current user is involved in the given project by
  # either of these ways:
  #
  #   * user is an admin in this project
  #   * user is a teammate
  #   * user is a lead_editor
  #   * user is a leader
  #   * user is a coordinator
  #
  # Returns boolean value
  def is_project_team_member?(project)
    is_admin_for?(project) ||
      project.team_memberships.exists?(team_member_id: id)
  end

  def is_task_team_member?(task)
    task_memberships = task.project.team.team_memberships
    task_memberships.collect(&:team_member_id).include? self.id
  end

  # Returns true if users are teammates in any project (or when compared to self)
  # Used for displaying contact info
  def is_teammate_with?(user)
    return true if self == user
    teams.each do |team|
      return true if team.project.present? && (team.project.team_members.include? self) && (team.project.team_members.include? user)
    end
    return false
  end

  def is_task_assignee?(task)
    id.in? task.assignments.pluck(:user_id)
  end

  def can_apply_as_admin?(project)
    !self.is_project_leader?(project) && !self.is_team_admin?(project.team) && !self.has_pending_admin_requests?(project)
  end

  def is_team_admin?(team)
    team.team_memberships.where(team_member_id: self.id, role: TeamMembership.roles[:admin]).any?
  end

  def has_pending_admin_requests?(project)
    self.admin_requests.where(project_id: project.id, status: AdminRequest.statuses[:pending]).any?
  end

  def has_pending_apply_requests?(proj, type)
    self.apply_requests.where(project_id: proj.id, request_type: type).pending.any?
  end

  def can_submit_task?(task)
    return unless task.doing?
    task_memberships = task.team_memberships
    self.is_project_leader_or_coordinator_or_admin?(task.project) || (
    task_memberships.collect(&:team_member_id).include?(self.id) &&
      self.is_teammate_for?(task.project)
    )
  end

  # Normal use case, username cannot be changed, need to bypass validation if neccessary
  def validate_username_unchange
    errors.add(:username, 'is not allowed to change') if username_changed? && self.persisted?
  end

  # if real name(First name + Last name) is not empty, display it instead of username, otherwise keep username
  def display_name
    (first_name.blank? && last_name.blank?) ?  username : full_name
  end

  def full_name
    [first_name, last_name].join(" ").strip
  end

  # Autocomplete display result (used in GroupMessagesController)
  def search_display_results
    User.find(id).display_name
  end

  # Hide user and all projects he is a member of
  def hide!
    Project.all.each do |project|
      project.hide! if project.team_members.include? self
    end
    self.hidden = true
    self.save
  end

  # Un-hide (make visible) user and all projects he is a member of if owners of those projects aren't hidden
  def un_hide!
    self.hidden = false
    self.save
    Project.all.each do |project|
      project.un_hide! if ((project.team_members.include? self) && !project.user.hidden)
    end
  end

  def online?
    last_seen_at.present? && last_seen_at > 5.minutes.ago
  end

  def self.fulltext_search(free_text, limit = 10)
    common_fulltext_search(
      %i(username first_name last_name bio), free_text, limit
    )
  end

  def create_balance
    build_balance.save
  end

  def create_external_card(stripeToken)
    return false, "Provide Payout details first" unless acc_id
    stripe_acc = Payments::Stripe.retrive_acc(acc_id)
    return false, stripe_acc[1] if stripe_acc[0].eql?(false)
    begin
      response = stripe_acc[1].external_accounts.create({external_account: stripeToken})
      card = build_credit_card(card_id: response.id, status: CreditCard::statuses[:new_card], last4: response.last4)
      card.save!
      update_card_details_stripe(response)
      return true, "Success"
    rescue Stripe::CardError => error
      return false, error.message
    rescue => error
      return false, error.message
    end
  end


  def update_card_details_stripe(card)
    begin
      return if card.nil?
      card.name = payout_detail.full_name
      card.address_country = payout_detail.country
      card.address_line1 = payout_detail.address
      card.address_state = payout_detail.state
      card.address_city = payout_detail.city
      card.address_zip = payout_detail.postal_code
      card.save
    rescue => error
      return true, error.message
    end
  end

  def create_external_bank(options = {})
    return false, "Provide Payout details first" unless acc_id
    res = Payments::Stripe.external_acc_bank(options.merge!("acct_id"=> acc_id, "account_holder_name"=> payout_detail.full_name))
    if res[0].eql?(true)
      create_bank(acct_id: res[1].id, status: Bank::statuses[:new_bank], last4: res[1].last4)
      return true, "Success"
    else
      return false, res[1]
    end
  end

  def delete_external_accounts(options = {})
    return false, "Please provied valid params" if options.nil?
    return false, "Provide Payout details first" unless acc_id
    if options["remove"].eql?("bank")
      external_acct_id = bank.acct_id
      external_bank_type = true
    else
      external_acct_id = credit_card.card_id
      external_bank_type = false
    end
    res = Payments::Stripe.delete_external_acct(options.merge("acct_id"=> acc_id, "external_acct_id" => external_acct_id))
    if res[0].eql?(true)
      external_bank_type ? bank.delete : credit_card.delete
      return true, "Deleted"
    else
      return false, res[1]
    end
  end

  def configured?
    custom_account.try(:status).eql?("verified")
  end

  def payout_transaction(sourcetype)
    return false, "Provide Source Type" if sourcetype.nil?
    # collect platform fee here
    amount = balance.amount
    amount_without_fee, fee = PayoutTransactionService.get_fee_from_payout(amount)
    currency = ENV['currency'].downcase
    card_bank_id = sourcetype.eql?("bank_account") ? bank.acct_id : credit_card.card_id
    conn_acc = custom_account.acc_id
    old_available_balance = Stripe::Balance.retrieve(stripe_account: conn_acc)["available"][0]["amount"]
    tran_conn_acc = Payments::Stripe.transfer_to_conn_acc({amount: amount_without_fee, currency: currency,
     destination: conn_acc })

    return false, tran_conn_acc[1] unless tran_conn_acc[0]

    # ----------------------------------------------------------------------
    result_balance = Stripe::Balance.retrieve(stripe_account: conn_acc)
    available_balance = result_balance["available"][0]
    amount = available_balance["amount"] - old_available_balance

    #tran_exter_acc = Payments::Stripe.transfer_to_external_acc({amount: amount_without_fee, currency: currency,
    # card_bank_id: card_bank_id, source_type: sourcetype, conn_acc: conn_acc})

    tran_exter_acc = Payments::Stripe.transfer_to_external_acc({amount: amount, currency: available_balance["currency"],
     card_bank_id: card_bank_id, source_type: "card", conn_acc: conn_acc})
    # not sure about source_type = card, need to dive deeper into Stripe docs
    # but for now it looks like all the transfers made from platform to connected account being references as "card"
    # and hence increase card source_type available balance
    # ------------------------------------------------------------------------

    unless tran_exter_acc[0]
      Payments::Stripe.reverse_transfer(tran_conn_acc[1].id)
      return false, tran_exter_acc[1]
    end

    PayoutTransactionService.create_payout_history({user: self, payout_provider: PayoutTransaction.payout_providers["stripe"], target_account:
      conn_acc, transaction_id: tran_conn_acc[1].id, status: PayoutTransaction.payout_status(tran_exter_acc[1].status),
      amount: balance.amount, fee: fee, payout_id: tran_exter_acc[1].id})

    # send notification to user
    PayoutMailer.request_withdrawal(balance.amount, self).deliver_later

    update_amount_nil
    return true, 'Success'
  end

  def update_amount_nil
    balance.amount = 0
    balance.save!
  end

  # get all transactions for showing to user in "My Wallet" page
  def all_transaction_histories
    all_transactions = []

    all_transactions << payment_transactions
    all_transactions << payout_transactions
    all_transactions << transaction_histories

    all_transactions.flatten.sort_by { |t| t.created_at }.reverse
  end

  def hold_amount
    hold_balances.sum(:amount)
  end

  def is_coordinator_leader_owner?(task)
    self.is_project_leader_or_coordinator?(task.project) || suggested_task_owner?(task)
  end

  # user is task owner but NOT *is_coordinator_leader_owner?*
  def suggested_task_owner?(task)
    task.suggested_task? && (self == task.user)
  end

  def admin?
    super || self[:admin]
  end

  def tasks
    Task.where(user_id: id)
  end

  def number_projects_user_leading
    projects.count
  end

  def total_donations_amount
    TransactionHistory.where(entity: id, operation_type: "decrease", source_type: "Task").map(&:amount).sum
  end

  def total_number_tasks_user_assignee
    assignments.count
  end

  def completed_tasks_ids
    assignments.completed.map(&:task_id)
  end

  def completed_tasks_count
    assignments.completed.count
  end

  def percent_tasks_user_successfully_completed
    total_number_tasks_user_assignee > 0 ? (completed_tasks_count.to_f / total_number_tasks_user_assignee * 100).round(2) : 0
  end

  def total_amount_funds_received_by_user
    TransactionHistory.where(entity: id, operation_type: "increase", source_id: completed_tasks_ids, source_type: "Task").map(&:amount).sum
  end

  def user_history_task_reviews
    TaskReview.where(task_id: completed_tasks_ids)
  end

  def user_average_rating
    reviews = user_history_task_reviews
    reviews.present? ? (reviews.map(&:rating).sum / reviews.count).round : 0
  end

  protected

  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def email_required?
    provider.blank? || uid.blank?
  end
end
