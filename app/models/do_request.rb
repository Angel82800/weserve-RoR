class DoRequest < ActiveRecord::Base
	include AASM

  default_scope -> { order('created_at DESC') }

  belongs_to :task
  belongs_to :user
  belongs_to :project

  validate :existed_valid_request, on: [:create]
  aasm :column => 'state', :whiny_transitions => false do
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


  def assign_and_update_task
    # Do not allow to accept "free" do requests
    # if there is some funds already donated to the task

    free_task = task.any_fundings? ? false : free
    user.assign(task, free_task)
    task.update(
      deadline: task.created_at + 60.days,
      number_of_participants: task.try(:number_of_participants).to_i + 1
    )
    task.update(free: true) if free_task
    task.send_notification_task_started if task&.fully_funded_and_enough_teammembers? && task&.start_doing!
    task
  end

  def task_board_id
    return unless task.board
    task.board.id
  end

	private

	def existed_valid_request
    pending_request = task.do_requests.where(
      user_id: user_id,
      state: :pending
    )

    is_assignee = task.team_memberships.find_by_team_member_id user_id

    if pending_request.any? || is_assignee
      errors[:base] << I18n.t("do_request.your_application_cannot_be_processed")
    end
	end
end
