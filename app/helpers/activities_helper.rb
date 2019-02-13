module ActivitiesHelper
  def activity_title(activity)
    activity.targetable_type.underscore.split('_').map!(&:upcase).join(' ')
  end

  def wiki_notifier(activity)
    "Wiki " + activity.action
  end

  def task_comment_notifier(activity)
    "Task comment " + activity.action
  end

  def activity_text(activity)
    send("#{activity.targetable_type.underscore}_notifier", activity)
  end

  def default_notifier(activity)
    object = activity.targetable
    content_tag(:div, nil, class: 'pro-text') do
      [
        # (link_to object.title, object),
        (link_to activity.try(:targetable_type), link_path(activity, object) ),
        " was successful #{activity.action}"
      ].join.html_safe
    end
  end

  def get_id(object)
    object_id = 1
    object_id = object.try(:id).nil? ? 1 : object.id
    object_id
  end

  def link_path(activity, object)
    #  get_link = "#{activity.targetable_type.underscore}".concat("_path(object)")
     get_link = "#{activity.targetable_type.underscore.pluralize}"
    #  send(get_link, object.try(:id), id: 2, Rails.application.routes.url_helpers)
    Rails.application.routes.url_for controller: get_link, action: :show, id: get_id(object), only_path: true
  end

  def user_notifier(activity)
    object = activity.targetable
    content_tag(:div, nil, class: 'pro-text') do
      [
        # (link_to object.title, object),
        (link_to activity.try(:targetable_type), object),
        " was successful #{activity.action}"
      ].join.html_safe
    end
  end

  alias_method :project_notifier, :default_notifier
  alias_method :task_notifier, :default_notifier

  def project_comment_notifier(activity)
    comment = activity.targetable
    content_tag(:div, nil, class: 'pro-text') do
      [
        (link_to 'The comment', [comment.project, comment]),
        " was successful #{activity.action}",
        " to this project ",
        (link_to comment.project.title, comment.project),
      ].join.html_safe
    end
  end
end
