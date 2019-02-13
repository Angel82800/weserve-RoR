class ApproveChangesTask < ActiveRecord::Base
  belongs_to :task
  belongs_to :assignment

  after_update :check_task

  def check_task
    if task.full_approve?
      task.update(task.change.merge(change: {}))
      task.approve_changes_tasks.destroy_all
    end
  end
end