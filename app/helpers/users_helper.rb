module UsersHelper
  def user_short_info(user)
    result = @user.location.to_s
    result += ' - ' if result.present?
    result += "Member since #{@user.created_at.strftime('%B %Y')}"
  end

  def project_budget(project)
    budget = 0
    project.tasks.to_a.each { |task|  budget += task.budget.try(:to_i) }
    budget
  end

  def project_funded(project)
    funded = 0
    project.tasks.to_a.each { |task|  funded += task.current_fund.try(:to_i) }
    funded
  end

  def team_members_count(project)
    members_count = 0
    members_count = project.team.team_members.count
    members_count
  end

  # different from the actual count, how many team members would the project owner like to have
  def team_members_count_target(project)
    members_count = 0
    members_count = project.team.slots
    members_count
  end

  def completed_task_count(project)
    task_count = 0
    project.tasks.each { |task| task_count+= 1 unless !task.completed? }
    task_count
  end

  def aliases_as
    "Silva, haha"
  end

  def conversation_companion_name(user, conversation)
    user.id != conversation.sender.id ? conversation.sender.display_name : conversation.recipient.display_name
  end

end
