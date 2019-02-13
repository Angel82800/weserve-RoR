module TasksHelper
  def freelancers_options
    s = ''
    User.all.each do |user|
      s << "<option value='#{user.id}' data-img-src='#{gravatar_image_url(user.email, size: 50)}'>#{user.display_name}</option>"
    end
    s.html_safe
  end

  def get_activity_detail(activity)
    case activity.targetable_type
    when 'Task'
      task_activity_detail(activity)
    when 'TaskComment'
      task_comments_activity_detail(activity)
    when 'TeamMembership'
      team_membership_activity_detail(activity)
    end
  end

  def task_activity_detail(activity)
    if activity.created?
      t('.task_proposed_by')
    elsif activity.edited?
      t('.task_edited_by')
    elsif activity.incomplete?
      t('.task_reviewed_and_rejected_by')
    end
  end

  def task_comments_activity_detail(_activity)
    t('.task_commented_by')
  end

  def team_membership_activity_detail(activity)
    if activity.deleted?
      t('.member_removed_from_task',
        member: activity.archived_targetable.team_member.display_name)
    end
  end

  def can_make_request_free?(task)
    !(task.free || task.any_fundings?)
  end
end
