class AdminInvitationsController < ApplicationController
  load_and_authorize_resource
  before_action :set_admin_invitation, only: [:accept, :reject]

  def create
    @admin_invitation = AdminInvitation.new(create_params)

    authorize! :create, @admin_invitation

    respond_to do |format|
      if @admin_invitation.save
        format.json { render json: @admin_invitation, status: :ok }
      else
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  def accept
    authorize! :accept, @admin_invitation

    respond_to do |format|
      if @admin_invitation.update(status: AdminInvitation.statuses[:accepted])
        TeamService.add_admin_to_project(@admin_invitation.project, @admin_invitation.user)

        flash[:notice] = t('.success')
        format.js { render json: {}, status: :ok }
      else
        flash[:error] = t('.fail')
        format.js { render json: { success: false } }
      end
    end
  end

  def reject
    authorize! :reject, @admin_invitation

    respond_to do |format|
      if @admin_invitation.update(status: AdminInvitation.statuses[:rejected])
        flash[:notice] = t('.success')
        format.js { render json: {}, status: :ok }
      else
        flash[:error] = t('.fail')
        format.js { render json: { success: false } }
      end
    end
  end

  private

  def set_admin_invitation
    @admin_invitation = AdminInvitation.find(params[:id])
  end

  def create_params
    params.require(:admin_invitation).permit(:user_id, :project_id, :sender_id, :controller)
  end
end
