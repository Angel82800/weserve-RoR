class AdminRequestsController < ApplicationController
  load_and_authorize_resource
  before_action :set_admin_request, only: [:accept, :reject]

  def create
    @admin_request = AdminRequest.new(create_params)

    authorize! :create, @admin_request

    respond_to do |format|
      if @admin_request.save
        format.json { render json: @admin_request.id, status: :ok }
      else
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  def accept

    authorize! :accept, @admin_request

    respond_to do |format|
      if @admin_request.update(status: AdminRequest.statuses[:accepted])
        TeamService.add_admin_to_project(@admin_request.project, @admin_request.user)
        Chatroom.add_user_to_project_chatroom(@admin_request.project, @admin_request.user)
        format.json { render json: @admin_request.id, status: :ok }
      else
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  def reject

    authorize! :reject, @admin_request

    respond_to do |format|
      if @admin_request.update(status: AdminRequest.statuses[:rejected])
        format.json { render json: @admin_request.id, status: :ok }
      else
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_admin_request
    @admin_request = AdminRequest.find(params[:id])
  end

  def create_params
    params.require(:admin_request).permit(:user_id, :project_id)
  end
end
