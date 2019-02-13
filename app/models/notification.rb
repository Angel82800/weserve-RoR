class Notification < ActiveRecord::Base
  enum action: [
      :default,
      :became_project_admin,
      :lost_project_admin_status,
      :created_project,
      :updated_project,
      :admin_request,
      :reject_admin_request,
      :accept_admin_request,
      :suggested_task,
      :pending_do_request,
      :leader_change,
      :change_leader_invitation,
      :change_leader_invitation_sent,
      :apply_request,
      :accept_apply_request,
      :reject_apply_request,
      :follow_project,
      :accept_task,
      :rejected_task
  ]

  enum action_type: [:text, :operatable]

  belongs_to :user
  belongs_to :origin_user, :foreign_key => 'origin_user_id', :class_name => 'User'
  belongs_to :source_model, polymorphic: true

  validates :user, presence: true
  validates :source_model, presence: true

  def self.unread
    where(:read => false)
  end

  def self.operatable?
    self.action_type == 'operatable'
  end

  def archived_source_model
    source_model_type.constantize.only_deleted.find_by(id: source_model_id) if source_model_type.constantize.method_defined?(:only_deleted)
  end
end
