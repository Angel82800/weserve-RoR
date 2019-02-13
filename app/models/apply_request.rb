class ApplyRequest < ActiveRecord::Base
  enum request_type: [:Lead_Editor, :Coordinator]

  belongs_to :user
  belongs_to :project

  validates :user, presence: true
  validates :project, presence: true

  scope :pending, -> { where("accepted_at IS NULL and rejected_at IS NULL") }

  def user_name
    user.display_name
  end

  def is_valid?
    accepted_at.nil? && rejected_at.nil?
  end

  def accept!
    self.update(accepted_at: Time.current)
  end

  def reject!
    self.update(rejected_at: Time.current)
  end

  def resolved_state
    return if is_valid?
    accepted_at ? 'accepted' : 'rejected'
  end
end
