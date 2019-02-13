class DoRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_do_request, except: [:new, :create]
  before_action :ensure_can_accept_request, only: [:accept]

  def new
    @task = Task.find(params[:task_id])

    if @task.suggested_task?
      flash[:error] = t('.fail')
      redirect_to task_path(@task.id)
    end

    @free = params[:free]
    @do_request = DoRequest.new
  end

  def create
    task = Task.find(request_params[:task_id])
    flash[:error] = t('.do_requests.new.fail') if task.suggested_task?

    @do_request = current_user.do_requests.build(request_params)
    @do_request.project_id = task.project_id
    @do_request.state = 'pending'

    respond_to do |format|
      if @do_request.save

        project = task.project
        # leader coordinators
        ([project.leader] + project.project_coordinators).flatten.each do |receiver|
          RequestMailer.to_do_task(receiver, requester: current_user, task: task).deliver_later
        end

        flash[:notice] = t('.success_and_sent')
        flash[:notice] = t('.success_and_will_notify_back') if current_user.id == task.project.user_id

        format.js
        format.html { redirect_to @do_request.task }
      else
        flash[:error] = @do_request.errors[:base]

        format.js
        format.html { redirect_to root_url }
      end
    end
  end

  def destroy
    @do_request.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_path, notice: t('.success') }
      format.json { head :no_content }
    end
  end

  def accept
    # leader/coordinator can process approve
    if !@do_request.task&.enough_teammembers? && @do_request.accept!
      task = @do_request.assign_and_update_task
      team = Team.find_or_create_by(project_id: @do_request.project_id)
      user = @do_request.user

      membership = set_membership(task, team, user)
      TaskMember.find_or_create_by(task_id: task.id, team_membership_id: membership.id)

      RequestMailer.accept_to_do_task(do_request: @do_request).deliver_later
      # temporary disabled in favour of upcoming chat feature
      # emails = task.interested_users.map(&:email)
      # NotificationMailer.notify_assignee_added_to_task(user, task, emails).deliver_later
      flash[:notice] = t('.success')
    else
      flash[:error] = t('.fail')
    end
    respond_to do |format|
      format.html {redirect_to taskstab_project_path(@do_request.project, tab: 'requests')}
      format.js
    end
  end

  def reject
    authorize! :reject, @do_request

    if @do_request.reject!
      RequestMailer.reject_to_do_task(do_request: @do_request).deliver_later
      flash[:notice] = t('.success')
    else
      flash[:error] = t('.fail')
    end
    respond_to do |format|
      format.html {redirect_to taskstab_project_path(@do_request.project, tab: 'requests')}
      format.js
    end
  end

  private

  def request_params
    params.require(:do_request).permit(:application, :task_id, :user_id, :free)
  end

  def get_do_request
    @do_request = DoRequest.find(params[:id])
  end

  def ensure_can_accept_request
    authorize! :accept, @do_request

    # prevent leader/coordinator approve the do request for a task
    # that has some fundings
    return unless (@do_request.free && @do_request.task.any_fundings?)
    flash[:error] = t('.cannot_approve')
    @do_request.reject!
    return respond_to do |format|
      format.html {redirect_to taskstab_project_path(@do_request.project, tab: 'requests')}
      format.js
    end
  end

  def set_membership(task, team, user)
    membership = team.team_memberships.find_by_team_member_id user.id
    return membership if membership

    # create new membership
    membership = team.team_memberships.new(
      team_member_id: user.id,
      role: :teammate
    )
    if membership.save
      Chatroom.add_user_to_project_chatroom(task.project, user.id)
      return membership
    end
  end
end
