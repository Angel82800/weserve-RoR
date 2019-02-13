module AbilityTask
  def leader_or_coordinator(task, user)
    user.is_project_leader_or_coordinator?(task.project)
  end

  def leader_or_coordinator_or_admin(task, user)
    leader_or_coordinator(task, user) || user.admin?
  end

  def leader_or_coordinator_or_admin_can_update_task(task, user)
    task.suggested_or_accepted_task? && leader_or_coordinator_or_admin(task, user)
  end

  def can_suggested_task(task, user)
    task.suggested_task? && !leader_or_coordinator(task, user)
  end

  def can_funding_task(task, user)
    task.accepted? && leader_or_coordinator(task, user)
  end

  def accept_task(user,task)
    task.suggested_task? && user.is_project_leader_or_coordinator_or_admin?(task.project)
  end

  def reviewing_or_doing_task(task)
    task.reviewing? || task.doing?
  end

  def reject_task(user, task)
    task.current_fund.zero? && task.accepted? && user.is_project_leader_or_coordinator_or_admin?(task.project)
  end

  def reviewing_task(user, task)
    user.can_submit_task?(task) || ( task.doing? && user.is_project_leader_or_coordinator_or_admin?(task.project))
  end

  def completed_task(user, task)
    (task.reviewing? || task.doing?) && user.is_project_leader_or_coordinator_or_admin?(task.project)
  end

  def doing_task(user, task)
    task.accepted? && user.is_task_team_member?(task)
  end

  def back_reviewing_task(user, task)
    task.completed? && user.is_project_leader_or_coordinator_or_admin?(task.project)
  end

  def incomplete_task(user, task)
    ((task.doing? && task.deadline < Time.current) || task.reviewing?) && leader_or_coordinator_or_admin(task, user)
  end

  def back_doing_task(user, task)
    task.reviewing? && user.is_project_leader_or_coordinator_or_admin?(task.project)
  end

  def remove_member_task(user, task)
    %w(suggested_task accepted incompleted).include?(task.state) &&
        (user.is_project_leader_or_coordinator_or_admin?(task.project) ||
            user.is_lead_editor_for?(task.project))
  end

  def create_task(user, task)
    can_suggested_task(task, user) || can_funding_task(task, user) || user.admin?
  end

  def update_deadline_task(user, task)
    task.incompleted? && (user.is_project_leader_or_coordinator_or_admin?(task.project))
  end

  def task_assignee_or_admin(user, task)
    user.is_task_assignee?(task) || user.admin?
  end
end
