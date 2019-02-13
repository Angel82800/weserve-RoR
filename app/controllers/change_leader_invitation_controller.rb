class ChangeLeaderInvitationController < ApplicationController
  def accept
    @invitation = ChangeLeaderInvitation.find params[:id]
    @invitation.accept!
    project = @invitation.project
    previous_leader = project.user
    if project.update(user_id: current_user.id)
      flash[:notice] = t('.success', project_title: @invitation.project.title)
      project.team.team_members.each do |user|
        NotificationsService.notify_about_leader_change(user, current_user, project)
      end

      InvitationMailer.notify_previous_leader_for_new_leader(project: project, previous_leader: previous_leader).deliver_later
    else
      flash[:alert] = project.errors.messages.to_s
    end
    redirect_to :my_projects
  end

  def reject
    @invitation = ChangeLeaderInvitation.find params[:id]
    @invitation.reject!

    redirect_to :my_projects
  end
end
