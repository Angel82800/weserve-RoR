class ProjAdminsController < ApplicationController
	load_and_authorize_resource
	before_action :set_proj_admin, only: [:accept, :reject]

	def create
		@proj_admin = ProjAdmin.new(proj_admin_params)
		if @proj_admin.save!
			flash[:success] = "Auxiliary admin assigned"
		else
			flash[:error] = "Auxiliary admin was not assigned"
		end
		redirect_to @proj_admin.project
	end

	def accept
		if @proj_admin.accept!
			flash[:success] = "Auxiliary Admin request accepted"
		else
      flash[:error] = "Auxiliary Admin request not accepted"
		end
		redirect_to dashboard_path
	end

	def reject
		if @proj_admin.reject!
			flash[:success] = "Auxiliary Admin request rejected"
		else
      flash[:error] = "Auxiliary Admin request not rejected"
		end
		redirect_to dashboard_path
	end

private

	def set_proj_admin
		@proj_admin = ProjAdmin.find(params[:id])
	end

	def proj_admin_params
		params.require(:proj_admin).permit(:project_id, :user_id)
	end
end
