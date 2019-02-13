class ApplyRequestsController < ApplicationController
  load_and_authorize_resource
  before_action :set_apply_request, only: [:accept, :reject]

  def accept
    @apply_request.accept!

    if @apply_request.request_type == "Lead_Editor"
      project = @apply_request.project
      user    = @apply_request.user

      project.grant_permissions user.display_name
    end

    role = @apply_request.request_type == "Lead_Editor"? TeamMembership.roles[:lead_editor] : TeamMembership.roles[:coordinator]

    TeamService.add_team_member(@apply_request.project.team, @apply_request.user, role)
    RequestMailer.positive_response_in_project_involvement(apply_request: @apply_request).deliver_later
    Chatroom.add_user_to_project_chatroom(@apply_request.project, @apply_request.user)

    redirect_to taskstab_project_path(@apply_request.project, tab: 'requests')
  end

  def reject
    @apply_request.reject!

    RequestMailer.negative_response_in_project_involvement(apply_request: @apply_request).deliver_later

    redirect_to taskstab_project_path(@apply_request.project, tab: 'requests')
  end

  private
  def set_apply_request
    @apply_request = ApplyRequest.find(params[:id])
  end
end
