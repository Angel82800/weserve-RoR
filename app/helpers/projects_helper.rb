module ProjectsHelper
  def config_project
    @project.tap do |p|
      p.section_details.build(title: 'First Section Details') if current_user.is_admin_for?(@project) && p.section_details.blank?
    end
  end

  def discussion_context_tag(section_detail, field_name, format = :html)
    Differ.format = format
    changed_context = section_detail.discussions.of_field(field_name).first
    if changed_context
      Differ.diff_by_char(changed_context.context, section_detail.send(field_name).to_s).to_s.html_safe
    else
      section_detail.send(field_name).to_s.html_safe
    end
  end

  def discussion_change_tag(context1, context2)
    Differ.format = Differ::Format::Custom
    html = ""
    puts Differ.diff_by_char(context1, context2).send(:raw_array)
    Differ.diff_by_char(context1, context2).send(:raw_array).each do |item|
      html << item.to_s.html_safe if item.is_a?(Differ::Change) && (item.insert? || item.delete?)
    end
    html.html_safe
  end

  def section_details_content_tag(parent = nil)
    content_tag :ul do
      html_ul = ActiveSupport::SafeBuffer.new
      @project.section_details.of_parent(parent).completed.ordered.each do |child|
        html_ul << content_tag(:li) do
          html_li = link_to(child.title, "#section-detail-#{child.id}")
          html_li << section_details_content_tag(child) if child.childs.exists?
          html_li
        end
      end
      html_ul
    end

  end

  def get_project_title(project_id)
    Project.find(project_id).title rescue 'project not found'
    end

  def get_chatroom_title(chat_room_id)
    Chatroom.find(chat_room_id).name rescue 'room not found'
  end

  def get_project_team(chatroom_id)
      team_members_id = Groupmember.where(chatroom_id: chatroom_id).collect(&:user_id) rescue nil
      User.where(id:team_members_id ) rescue nil
  end

  def autocomplete_class_for(type)
    case type
    when 'project' then return 'glyphicon glyphicon-list-alt'
    when 'task' then return 'glyphicon glyphicon-tasks'
    when 'user' then return 'glyphicon glyphicon-user'
    end
  end

  def check_permisstion_cancel_task?(cancel_confirm, task_id)
    cancel_confirm == 'true' && task_id && (can? :back_funding, Task.find(task_id))
  end
end
