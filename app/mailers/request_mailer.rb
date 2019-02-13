class RequestMailer < ApplicationMailer
  def apply_to_get_involved_in_project(applicant:, project:, request_type:)
    leader = project.leader
    message_params = {
      "ApplicantName" => applicant.display_name,
      "RequestType" => request_type,
      "RequestTabUrl" => taskstab_project_url(project, tab: 'requests')
    }
    mailjet_notification(leader, project: project, additional_params: message_params)
  end

  def positive_response_in_project_involvement(apply_request:)
    set_instance_variables_for_project_involvement(apply_request)
    mailjet_notification(@applicant, exclude: [:receiver_name], additional_params: project_response_variables)
  end

  def negative_response_in_project_involvement(apply_request:)
    set_instance_variables_for_project_involvement(apply_request)
    mailjet_notification(@applicant,  exclude: [:receiver_name], additional_params: project_response_variables)
  end

  def to_do_task(receiver, requester:, task:)
    additional_params = {
      "RequesterName" => requester.display_name,
      "RequestTabUrl" => taskstab_project_url(task.project, tab: 'requests')
    }
    mailjet_notification(receiver, exclude: [:receiver_name, :project], task: task, additional_params: additional_params)
  end

  def accept_to_do_task(do_request:)
    requester = do_request.user
    mailjet_notification(requester, task: do_request.task,  requester: requester,  exclude: [:receiver_name])
  end

  def reject_to_do_task(do_request:)
    requester = do_request.user
    mailjet_notification(requester, task: do_request.task, requester: requester,  exclude: [:receiver_name])
  end

  private
  def set_instance_variables_for_project_involvement(apply_request)
    @applicant = apply_request.user
    @request_type = apply_request.request_type.try(:gsub, '_', ' ')
    @project = apply_request.project
  end

  def project_response_variables
    variables = {
      "RequestType" => @request_type,
      "ProjectTitle" => @project.title,
      "ProjectUrl" => project_url(@project.id),
    }
    variables.merge({"LeaderName" => @project.leader.try(:display_name)}) if @project.leader.try(:display_name)
  end
end
