class NotificationMailer < ApplicationMailer
  include ActionView::Helpers::TextHelper
  def invite_admin(admin, project)
    mailjet_notification(admin, project: project)
  end

  def suggest_task(user, task)
    mailjet_notification(user, project: task.project, suggestor: task.user)
  end

  def accept_new_task(task:, receiver:)
    mailjet_notification(receiver, task: task)
  end

  def reject_task_to_suggested(task, receiver)
    mailjet_notification(receiver, task: task)
  end

  def task_started(acting_user:, task:, receiver:)
   mailjet_notification(receiver, task: task, user: acting_user)
  end

  def task_changed(task:, receiver:, reviewer:)
   mailjet_notification(receiver, task: task, reviewer: reviewer)
  end

  def under_review_task(reviewee:, task:, receiver:)
   mailjet_notification(receiver, task: task, reviewee: reviewee)
  end

  # def back_review_task(reviewee:, task:, receiver:)
  #   @task = task
  #   @reviewee = reviewee
  #   @receiver = receiver
  #
  #   mail(to: receiver.email, subject: t('.subject'))
  # end

  def task_back_inprogress(task, receiver)
    mailjet_notification(receiver, task: task)
  end

  def revision_approved(approver:, project:, receiver:)
    mailjet_notification(receiver, project: project, approver: approver)
  end

  def task_change_rejected(approver:, task:, receiver:)
   mailjet_notification(receiver, task: task, approver: approver)
  end

  def task_change_approved(approver:, task:, receiver:)
   mailjet_notification(receiver, task: task, approver: approver)
  end

  def notify_user_for_rejecting_new_task(task:, project:, receiver:)
    mailjet_notification(receiver, task: task, project: project)
  end

  def notify_others_for_rejecting_new_task(task:, project:, receiver:)
    mailjet_notification(receiver, task: task, project: project)
  end

  def comment(task_comment:, receiver:, board_id:)
    message_params = {
      "TaskTitle" => task_comment.task.title,
      "TaskUrl" => taskstab_project_url(task_comment.task.project.id, tab: 'tasks', board: board_id, taskId: task_comment.task.id),
      "Comment" => truncate(task_comment.body, length: 160)
    }
    mailjet_notification(receiver, user: task_comment.user, additional_params: message_params)
  end

  def task_deleted(task:, project:, receiver:, admin:)
    mailjet_notification(receiver, task: task, project: project, admin: admin)
  end

  def task_completed(task:, receiver:, reviewer:)
   mailjet_notification(receiver, task: task, reviewer: reviewer)
  end

  def task_incomplete(task:, receiver:, reviewer:)
   mailjet_notification(receiver, task: task, reviewer: reviewer)
  end

  def cancel_request_task (task, assignee, receiver)
    additional_params = {
      "TaskTitle" => task.title,
      "ConfirmationUrl" => taskstab_project_url(task.project, tab: 'tasks', cancel_confirm: true, task_id: task.id, assignee_id: assignee.id)
    }
    mailjet_notification(receiver, assignee: assignee, additional_params: additional_params)
  end

  def notify_assignee_on_removing_from_task(assignee, task)
    mailjet_notification(assignee, task: task,  exclude: [:project])
  end

  # Temporarily disabled as per Eric's suggestion
  # def notify_assignee_added_to_task(assignee, task, emails)
  #   message_params = {
  #       "TemplateID" => template_id,
  #       "Variables" => mailjet_variables(assignee, task: task, exclude: [:project])
  #   }
  #   mail(
  #       to: assignee.email,
  #       subject: '',
  #       cc: emails,
  #       body: '',
  #       delivery_method_options: prep_mailjet_options(message_params)
  #   )
  # end

  def notify_interested_user_on_removing_from_task(assignee, interested_user, task)
    mailjet_notification(interested_user, assignee: assignee, task: task,  exclude: [:project])
  end

  def new_message(group_message_id, user_id)
    group_message = GroupMessage.find(group_message_id)
    message = group_message.message
    from = group_message.user
    receiver = User.find(user_id)
    message_params = { "Message" => message }
    mailjet_notification(receiver, user: from, additional_params: message_params)
  end

  def stripe_account_update(user_id, prev_status)
    receiver = User.find(user_id)
    curr_status = receiver.custom_account.status

    additional_params = {
      "PreviousState" => prev_status,
      "CurrentState" => curr_status
    }
    mailjet_notification(receiver, additional_params: additional_params)
  end


  def block_withdraw(user_id)
    receiver = User.find(user_id)
    mailjet_notification(receiver)
  end

  def send_warning_mail(user_id, due_date)
    receiver = User.find(user_id)
    additional_params = { "DueDate" => due_date }
    mailjet_notification(receiver, additional_params: additional_params)
  end

  def fund_available(user_id, amount)
    receiver = User.find(user_id)
    additional_params = { "Amount" => amount }
    mailjet_notification(receiver, additional_params: additional_params)
  end

  def send_error_to_admin(user, error)
   return  if ENV["admin_notification_email"].nil?
   receiver =  ENV["admin_notification_email"]
   error = error
   message_params = {
       "TemplateID" => template_id,
       "Variables" => {
           "UserDetail" => "#{user.display_name}(#{user.id})",
           "Error" => error
       }
   }
   mailjet_mail(receiver, message_params)
  end

  # when the user is changed to new leader by the admin
  def notify_new_leader_for_project(project:, previous_leader:)
    mailjet_notification(project.user, previous_leader: previous_leader, project: project)
  end
end
