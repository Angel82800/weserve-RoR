class InvitationMailer < ApplicationMailer
  def invite_user(email, user_name, task )
    receiver = User.find_by(email: email)
    message_params = { "InviterName" => user_name }
    mailjet_notification(receiver, exclude: [:receiver_name, :project], task: task, additional_params: message_params)
  end

  def invite_user_for_project(email, user_name, project_id)
    receiver = User.find_by(email: email)
    project = Project.find(project_id)
    message_params = { "InviterName" => user_name }
    mailjet_notification(receiver, exclude: [:receiver_name], project: project, additional_params: message_params)
  end

  def invite_leader(invitation_id)
    invitation = ChangeLeaderInvitation.find invitation_id
    from = invitation.project.user.email
    new_leader = User.find_by(email: invitation.new_leader)

    message_params = { "ReceiverName" => invitation.new_leader, "InviterName" => from }
    mailjet_notification(new_leader, exclude: [:receiver_name], project: invitation.project, additional_params: message_params)
  end

  def notify_previous_leader_for_new_leader(project:, previous_leader:)
    mailjet_notification(previous_leader, new_leader: project.user, project: project)
  end

  def welcome_user(email_address)
    user = User.find_by(email: email_address)
    mailjet_notification(user)
  end
end
