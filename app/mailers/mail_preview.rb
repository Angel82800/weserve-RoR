class MailPreview < MailView

  def task_share_email
    email = 'new_user@test.com'
    user_name = 'inviting_user'
    task = Task.first
    InvitationMailer.invite_user(email,user_name,task )
  end

  def project_share_email
    email = 'new_user@test.com'
    user_name = 'inviting_user'
    project_id = Project.first.id

    InvitationMailer.invite_user_for_project(email,user_name,project_id)
  end

  def task_incomplete_email
    reviewer = User.first
    receiver = User.first
    task = Task.first

    NotificationMailer.task_incomplete(reviewer: reviewer, task: task, receiver: receiver)
  end
    
  def project_page_text_edited
    editor = User.first
    receiver = User.second
    project = Project.first

    ProjectMailer.project_page_text_edited(project_id: project.id, editor_id: editor.id, receiver_id: receiver.id)
  end

  def project_sub_page_text_edited
    editor = User.first
    receiver = User.second
    project = Project.first
    sub_page = "Sub Page Title"

    ProjectMailer.project_sub_page_text_edited(project_id: project.id, sub_page: sub_page, editor_id: editor.id, receiver_id: receiver.id)
  end

end
