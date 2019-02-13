class ProjectMailer < ApplicationMailer

  def project_text_edited_by_leader(project_id:, editor_id:, receiver_id:)
    project_text_change(project_id: project_id, editor_id: editor_id, receiver_id: receiver_id)
  end

  def project_text_submitted_for_approval(project_id:, editor_id:, receiver_id:)
    project_text_change(project_id: project_id, editor_id: editor_id, receiver_id: receiver_id)

  end

  def project_text_edited(project_id:, editor_id:, receiver_id:)
    project_text_change(project_id: project_id, editor_id: editor_id, receiver_id: receiver_id)
  end

  # def project_sub_page_text_edited(project_id:,sub_page:, editor_id:, receiver_id:)
  #   @project_title = Project.find(project_id).title
  #   @editor_display_name = User.find(editor_id).display_name
  #   @receiver_display_name = User.find(receiver_id).display_name
  #   @sub_page = sub_page

  #   mail(to: User.find(receiver_id).email, subject: t('.subject'))
  # end

  private

  def project_text_change(project_id:, editor_id:, receiver_id:)
    project_title = Project.find(project_id).title
    editor_display_name = User.find(editor_id).display_name
    additional_params = { "EditorName" => editor_display_name, "ProjectTitle" => project_title }
    mailjet_notification(User.find(receiver_id), additional_params: additional_params)
  end
end
