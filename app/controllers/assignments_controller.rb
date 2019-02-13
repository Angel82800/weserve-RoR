class AssignmentsController < ApplicationController
  def new
    @assignment = Assignment.new
  end

  def create
    @assignment = Assignment.new(assignment_params)
    if @assignment.save!
      project = Project.find @assignment.project_id
      user = User.find @assignment.user_id
      project.follow!(user)
      flash[:success] = "Task assigned"
    else
      flash[:error] = "Task was not assigned"
    end
    redirect_to @assignment.task
  end

  def update_collaborator_invitation_status
    unless params[:collaborator_ids].blank?
      Assignment.where(user_id: params[:collaborator_ids] ).last.update_attribute('invitation_sent', true) rescue nil
    end
  end

  def accept
    @assignment = Assignment.find(params[:id])
    if @assignment.accept!
      @assignment.task.project.follow!(@assignment.user)
      flash[:success] = "Assignment accepted"
    else
      flash[:error] = "Assignment was not accepted"
    end
    redirect_to dashboard_path
  end

  def reject
    @assignment = Assignment.find(params[:id])
    if @assignment.reject!
      flash[:success] = "Assignment rejected"
    else
      flash[:error] = "Assignment was not rejected"
    end
    redirect_to dashboard_path
  end

  def completed
    @assignment = Assignment.find(params[:id])
    if @assignment.complete!
      flash[:success] = "Congrats! Admin will verify that assignment has been completed"
    else
      flash[:error] = "Sorry, something is wrong"
    end
    redirect_to dashboard_path
  end

  def confirmed
    @assignment = Assignment.find(params[:id])
    if @assignment.verify!
      @assignment.update_attribute(:confirmed_at, Time.now)
      flash[:success] = "Completion of assignment verified."
    else
      flash[:error] = "Completion of assignment not confirmed"
    end
    redirect_to dashboard_path
  end

  def confirmation_rejected
    @assignment = Assignment.find(params[:id])
    if @assignment.unconfirm!
      flash[:success] = "Comfirmation of assignment completion was rejected"
    else
      flash[:error] = "Comfirmation was not rejected"
    end
    redirect_to dashboard_path
  end

  private
  def assignment_params
    params.require(:assignment).permit(:task_id, :user_id, :free, :id)
  end
end
