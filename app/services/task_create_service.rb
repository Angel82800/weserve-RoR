class TaskCreateService
  attr_reader :task, :user, :project

  def initialize(task_params, user, project)
    raise ArgumentError, "Incorrect argument type" unless task_params.is_a?(Hash)
    raise ArgumentError, "Incorrect argument type" unless user.is_a?(User)
    raise ArgumentError, "Incorrect argument type" unless project.is_a?(Project)

    @task = project.tasks.new(task_params.merge(user_id: user.id))
    @task.target_number_of_participants = 1 unless @task.free
    @task.budget = @task.free ? 0 : CurrencyConversion.usd_to_cents(@task.budget)
    @user = user
    @project = project
  end

  def create_task
    return false unless task.valid?
    return false if !task.free? && !task_budget_is_greater_than_or_equal_to_a_minimum?
    ActiveRecord::Base.transaction do
      if task.save
        user.create_activity(task, 'created')
        # There are old projects with no team and creating a task adds user to the team, so a team need to be created
        unless task.project.team
          @project_team = task.project.create_team(name: "Team#{task.project.id}")
          TeamMembership.create(team_member_id: task.project.user.id, team_id: @project_team.id, role: 1 )
          task.project.user.create_activity(task.project, 'created')
          Chatroom.create_chatroom_with_groupmembers([task.project.user], 1, task.project)
        end
        # Suggesting a task adds user to teammates
        TeamService.add_team_member(task.project.team, user, "teammate") unless task.project.team.team_members.include? user
        true
      else
        false
      end
    end
  end

  private
  def task_budget_is_greater_than_or_equal_to_a_minimum?
    if task.budget >= Task::MINIMUM_FUND_BUDGET
      true
    else
      task.errors.add(:budget, 'must be higher than a minimum budget')
      false
    end
  end
end
