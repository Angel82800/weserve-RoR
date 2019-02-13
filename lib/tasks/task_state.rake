namespace :task_state do
  desc "Changed state from pending to suggested task"
  task change_state_from_pending_to_suggted_task: :environment do
    Task.where(state: "pending").update_all(state: "suggested_task")
  end
end
