class SubprojectsController < ApplicationController
  load_and_authorize_resource :project

  def index
    @projects = project.children
    respond_to do |format|
      format.js
      format.html {redirect_to taskstab_project_path(project.id, tab: 'subprojects')}
    end
  end

  def destroy
    authorize! :destroy, project
    unlink_project = Project.find(params[:id])
    unlink_project.update(parent: nil) if unlink_project.parent == project
    redirect_to action: :index, status: :see_other
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end
end
