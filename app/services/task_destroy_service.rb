class TaskDestroyService
  attr_reader :task, :user

  def initialize(task, user)
    raise ArgumentError, "Incorrect argument type" unless task.is_a?(Task)
    raise ArgumentError, "Incorrect argument type" unless user.is_a?(User)

    @task = task
    @user = user
  end

  def destroy_task
    task.update_current_fund!
    return false if task.any_fundings?

    ActiveRecord::Base.transaction do
      if task.destroy
        user.create_activity(task, 'deleted')
        true
      else
        false
      end
    end
  end


end
