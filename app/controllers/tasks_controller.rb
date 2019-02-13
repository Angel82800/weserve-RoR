class TasksController < ApplicationController
  before_action :set_task, only: [:show, :update, :update_task_in_progress, :destroy, :accept, :reject,
                                  :doing, :task_fund_info, :remove_member, :back_funding, :add_assignee, :remove_assignee, :create_task_review,
                                  :refund, :incomplete, :request_change, :preview, :set_approve_change_task]
  before_action :validate_user, only: [:accept, :doing, :incomplete]
  before_action :validate_team_member, only: [:reviewing]
  before_action :validate_admin, only: [:completed]
  protect_from_forgery except: [:update, :update_task_in_progress, :preview, :set_approve_change_task]
  before_action :authenticate_user!, only: [:send_email, :create, :destroy, :remove_assignee,
                                            :accept, :reject, :doing, :back_funding, :add_assignee, :create_task_review,
                                            :reviewing, :completed, :incomplete, :request_change]

  def show
    return redirect_to root_path, alert: t('.fail') if @task.blank?
    return redirect_to task_url(id: @task.id, board: @task.board_id, taskId: @task.id) if (params[:taskId].blank? || params[:board].blank?)

    @project = @task.project
    @comments = @project.project_comments.all
    @proj_admins_ids = @project.proj_admins.ids
    @current_user_id, @rate, @followed = 0, 0, false
    @boards = @task.boards_for_select
    if user_signed_in?
      @followed = @project.project_users.pluck(:user_id).include? current_user.id
      @current_user_id = current_user.id
      @rate = @project.project_rates.find_by(user_id: @current_user_id).try(:rate).to_i
    end
    tasks = @project.tasks.all
    @tasks_count = tasks.count
    @sourcing_tasks = tasks.where(state: 'accepted').all
    @done_tasks = tasks.where(state: 'completed').count

    @contents, @subpages, @is_blocked = @project.page_info(current_user)

    @histories = get_revision_histories @project

    @mediawiki_api_base_url = Project.load_mediawiki_api_base_url

    @apply_requests = @project.apply_requests.pending.all
    @task_comments = @task.task_comments
    @task_attachment = TaskAttachment.new
    @task_attachments = @task.task_attachments
    @task_memberships = @task.team_memberships
    @activities = Activity.for_task_and_comments(@task)
  end


  def show_share
    @task = Task.find(params[:id])
    @url = params[:url_server]
    render 'tasks/show_share', template: false, layout: false
  end


  # POST /tasks
  # POST /tasks.json
  def create
    project = Project.find(params[:task][:project_id])

    unless params[:task][:board_id].present?
      authorize! :create, project.tasks.new(state: params[:task][:state])
    end
    service = TaskCreateService.new(create_task_params, current_user, project)

    respond_to do |format|
      redirect_path = taskstab_project_path(project, tab: 'tasks', board: params[:task][:board_id])

      if service.create_task
        format.html {redirect_to redirect_path, notice: t('.notice_message')}
        format.json {render :show, status: :created, location: service.task}
      else
        format.html {redirect_to redirect_path, alert: t('.alert_message')}
        format.json {render json: service.task.errors, status: :unprocessable_entity}
      end
    end
  end

  def create_task_review
    review = TaskReview.new(user_id: current_user.id, task_id: @task.id, rating: params[:rating] || 0, feedback: params[:feedback])
    review.save
    redirect_to task_path(@task.id), format: :js
  end

  def task_fund_info
    respond_to do |format|
      format.json do
        needed_fund = CurrencyConversion.cents_to_usd(@task&.funds_needed_to_fulfill_budget)
        render json: {
            balance: @task.balance.funded, task_id: @task.id, project_id: @task.project_id, fund_required: needed_fund, status: 200
        }
      end
      format.html {redirect_to root_path, alert: t('tasks.validate_team_member.not_allowed')}
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    authorize! :update, @task
    respond_to do |format|
      @task_memberships = @task.team_memberships
      @board_changed = params["task"]["board_id"]
      if @task.update(update_task_params)
        current_user.create_activity(@task, 'edited')
        format.html {render nothing: true}
        format.json {render :show, status: :ok, location: @task}
        format.js
      else
        format.html {head :unprocessable_entity}
        format.json {render json: @task.errors, status: :unprocessable_entity}
        format.js
      end
    end
  end

  def update_task_in_progress
    authorize! :update_task_in_progress, @task
    @task.change.merge!(params['task'])
    if @task.save
      @task.approve_changes_tasks.destroy_all
      @task.assignments.each do |assignment|
        @task.approve_changes_tasks.create(assignment_id: assignment.id)
        NotificationMailer.task_changed(task: @task, receiver: assignment.user, reviewer: current_user).deliver_later
      end
    end
    render json: { task: @task, badge: t('tasks.preview.leader-badge_task_edited') }
  end

  def set_approve_change_task
    if params['approve']
      assignment_id = @task.assignments.find_by(user_id: current_user.id).id
      approve_changes_task = @task.approve_changes_tasks.find_by(assignment_id: assignment_id)
      approve_changes_task.update(approve: true)
      NotificationMailer.task_change_approved(approver: current_user, task: @task, receiver: @task.user).deliver_later
    else
      @task.update(change: {})
      @task.approve_changes_tasks.destroy_all
      NotificationMailer.task_change_rejected(approver: current_user, task: @task, receiver: @task.user).deliver_later if params['reject']
    end
    render json: @task
  end

  def preview
    if params['preview']
      badge = params['leader'] === 'true'  ? t('.leader-preview-mode') : t('.assignee-preview-mode')
      render json: { task: @task.change, badge: badge }
    else
      badge = params['leader'] === 'true' ? t('.leader-badge_task_edited') : t('.assignee-badge_task_edited')
      render json: { task: @task, badge: badge }
    end
  end

  def destroy
    authorize! :destroy, @task
    begin
      service = TaskDestroyService.new(@task, current_user)
      redirect_path = taskstab_project_path(@task.project, tab: 'tasks')

      if service.destroy_task
        flash[:notice] = t('.notice_message')
      else
        flash[:error] = t('.error_message')
      end
    rescue Payments::BTC::Errors::GeneralError => error
      ErrorHandlerService.call(error)
      flash[:error] = UserErrorPresenter.new(error).message
    end
    respond_to do |format|
      format.js {head :no_content}
      format.html {redirect_to redirect_path}
    end
  end

  def refund
    raise NotImplementedError, t('.refunds_disabled')
  end

  def accept
    authorize! :accept, @task

    if @task.accept!
      @notice = t('.task_accepted')
      # the user that suggested the task might not be a follower neither a team_member
      (@task.interested_users + [@task.user]).uniq.each do |user|
        NotificationMailer.accept_new_task(task: @task, receiver: user).deliver_later
      end
      NotificationsService.notify_about_accept_task(@task, @task.user)
    else
      @notice = t('.task_not_accepted')
    end
    respond_to do |format|
      format.js
      format.html {redirect_to taskstab_project_url(@task.project, tab: 'tasks', board: @task.board_id), notice: @notice}
    end
  end

  def reject
    authorize! :reject, @task
    if @task.reject_to_suggested!
      @notice = t('.task_rejected', task_title: @task.title)
      (@task.interested_users + [@task.user]).uniq.each do |user|
        NotificationMailer.reject_task_to_suggested(@task, user).deliver_later
      end
      NotificationsService.notify_about_rejected_task(@task)
    else
      @notice = t('.task_not_rejected')
    end
    respond_to do |format|
      format.js
      format.html {redirect_to taskstab_project_url(@task.project, tab: 'tasks'), notice: @notice}
    end
  end

  def back_funding
    authorize! :back_funding, @task
    if @task.back_funding!
      @notice = t('.task_cancelled', task_title: @task.title)
      update_task_cancel
    else
      @notice = t('.task_not_cancelled')
    end
    respond_to do |format|
      format.js
      format.html {redirect_to taskstab_project_url(@task.project, tab: 'tasks'), notice: @notice}
    end
  end

  def request_change
    authorize! :back_doing, @task
    if @task.back_doing!
      @notice = t('.task_back_doing')
      @task.interested_users.each do |user|
        NotificationMailer.task_back_inprogress(@task, user).deliver_later
      end
    else
      @notice = t('.task_not_back_doing')
    end

    redirect_to taskstab_project_url(@task.project, tab: 'tasks', board: @task.board_id), notice: @notice
  end

  def reviewing
    authorize! :reviewing, @task

    if current_user.can_submit_task?(@task) && @task.begin_review!
      @notice = t('.task_submitted')
      @task.interested_users.each do |user|
        NotificationMailer.under_review_task(reviewee: current_user, task: @task, receiver: user).deliver_later
      end
    else
      @notice = t('.task_not_sumitted')
    end

    respond_to do |format|
      format.js
      format.html {redirect_to taskstab_project_path(@task.project, tab: 'tasks', board: @task.board_id), notice: @notice}
    end
  end

  def completed
    authorize! :completed, @task

    service = TaskCompleteService.new(@task, current_user)

    @notice = t('.task_completed') if service.complete!

    @task.interested_users.each do |user|
      NotificationMailer.task_completed(task: @task, receiver: user, reviewer: current_user).deliver_later
    end

    respond_to do |format|
      format.js
      format.html {redirect_to taskstab_project_path(@task.project, tab: 'tasks', board: @task.board_id), notice: @notice}
    end
  rescue ArgumentError, Payments::BTC::Errors::GeneralError => error
    ErrorHandlerService.call(error)
    @notice = UserErrorPresenter.new(error).message

    respond_to do |format|
      format.js
      format.html {redirect_to taskstab_project_path(@task.project, tab: 'tasks'), notice: @notice}
    end
  end

  def incomplete
    authorize! :incomplete, @task

    @task.deadline = params[:task_deadline]
    if @task.valid?
      @task.incomplete!
    else
      flash[:error] = t('.fail')
      return redirect_to show_task_projects_path(id: @task.id)

    end

    @task.interested_users.each do |user|
      NotificationMailer.task_incomplete(reviewer: current_user, task: @task, receiver: user).deliver_later
    end
    task_incomplete_activity = Activity.new(
        user: current_user,
        action: "incomplete",
        targetable_id: @task.id,
        targetable_type: "Task"
    )
    task_incomplete_activity.save!
    redirect_to taskstab_project_path(@task.project, tab: 'tasks'), notice: t('.task_incompleted', task_title: @task.title, project_title: @task.project.title)
  end

  def send_email
    InvitationMailer.invite_user(params['email'], current_user.display_name, Task.find(params['task_id'])).deliver_later
    @notice = t('.task_link_sent', email: params[:email])
    respond_to :js
  end

  def remove_member
    authorize! :remove_member, @task

    @team_membership = @task.team_memberships.find(params[:team_membership_id])

    respond_to do |format|
      TeamMembership.transaction do
        begin
          # Must give reason to remove a member
          if params[:reason]
            assignee = @team_membership.team_member

            @team_membership.update!(deleted_reason: params[:reason])
            @team_membership.destroy!
            @task.decrement!(:number_of_participants, 1)
            current_user.create_activity(@team_membership, 'deleted')
            NotificationMailer.notify_assignee_on_removing_from_task(assignee, @task).deliver_later

            @task.interested_users.each do |user|
              NotificationMailer.notify_interested_user_on_removing_from_task(assignee, user, @task).deliver_later
            end

            flash[:notice] = t('.success')
            format.json {render json: @team_membership.id, status: :ok}
          else
            flash[:error] = t('.fail')
            format.json {render json: @team_membership.errors, status: :unprocessable_entity}
          end
        rescue
          format.json {render json: @team_membership.errors, status: :unprocessable_entity}
        end
      end
    end
  end

  def add_assignee
    authorize! :add_assignee, @task
    user = User.find params[:user_id]
    membership = @task.project.team_memberships.where(team_member_id: user.id).first
    if user.assign(@task, @task.free)
      update_add_assignee(membership.id)
      flash[:notice] = t('.success')
    else
      flash[:error] = t('.fail')
    end
    redirect_to taskstab_project_url(@task.project, tab: 'tasks', board: @task.board_id, taskId: @task.id)
  end

  def remove_assignee
    authorize! :remove_assignee, @task
    team_membership = TeamMembership.find params[:membership_id]
    if update_remove_assignee(team_membership)
      flash[:notice] = t('.success')
    else
      flash[:error] = t('.fail')
    end
    redirect_to taskstab_project_url(@task.project, tab: 'tasks', board: @task.board_id, taskId: @task.id)
  end

  def cancel
    @task = Task.find_by_id params[:id]
    authorize! :cancel, @task

    if current_user.admin?
      back_funding
    else
      # send a request mail to a project leader
      NotificationMailer.cancel_request_task(@task, current_user, @task.project.leader).deliver_later
      redirect_to taskstab_project_path(@task.project, tab: 'tasks', board: @task.board_id), notice: t('.success')
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_task
    @task = Task.find(params[:id]) rescue nil
    @pending_apply_requests = @task.do_requests.pending rescue []
  end

  def validate_user
    unless current_user.is_project_leader_or_coordinator_or_admin?(@task.project)
      flash[:error] = t('controllers.unauthorized_message')
      redirect_to taskstab_project_path(@task.project)
    end
  end

  def create_task_params
    params.require(:task).permit(default_attributes)
  end

  def update_task_params
    attributes = default_attributes
    attributes.delete(:deadline) if cannot? :update_deadline, @task
    if cannot? :update_budget, @task
      attributes.delete(:budget)
      attributes.delete(:free)
    end
    result_hash = params.require(:task).permit(attributes)
    if result_hash['budget']
      result_hash['budget'] = CurrencyConversion.usd_to_cents(result_hash['budget'])
    end

    if result_hash['free']
      result_hash['free'] = (result_hash['free'] == 'true')
      result_hash['budget'] = result_hash['free'] ? 0 : Task::MINIMUM_FUND_BUDGET
    end

    result_hash
  end

  def default_attributes
    %i(references project_id deadline target_number_of_participants
       short_description number_of_participants proof_of_execution title
       description budget user_id condition_of_execution fileone filetwo
       filethree filefour filefive state free board_id)
  end
  def validate_team_member
    @task= Task.find(params[:id]) rescue nil
    unless (current_user.can_submit_task?(@task) || current_user.is_project_leader_or_coordinator_or_admin?(@task.project))
      @notice = t('tasks.validate_team_member.not_allowed')
      respond_to do |format|
        format.js
        format.html {redirect_to task_path(@task.id), notice: @notice}
      end
    end
  end

  def validate_admin
    @task = Task.find(params[:id]) rescue nil
    if @task.blank?
      redirect_to '/'
    else
      unless can? :completed, @task
        @notice = t("tasks.validate_admin.not_allowed")
        respond_to do |format|
          format.js
          format.html {redirect_to task_path(@task.id), notice: @notice}
        end
      end
    end
  end

  def get_revision_histories(project)
    result = project.get_history
    @histories = []

    if result
      result.each do |r|
        history = Hash.new
        history["revision_id"] = r["id"]
        history["datetime"] = DateTime.strptime(r["timestamp"], "%s").strftime("%l:%M %p %^b %d, %Y")
        history["user"] = User.find_by_username(r["author"][0].downcase+r["author"][1..-1]) || User.find_by_username(r["author"])
        history["status"] = r['status']
        history["comment"] = r['comment']
        history["username"] = r["author"]
        history["is_blocked"] = r["is_blocked"]

        @histories.push(history)
      end
      return @histories
    else
      return []
    end
  end

  def update_task_cancel
    @task.assignments.destroy_all
    @task.do_requests.where(state: "accepted").destroy_all
    @task.number_of_participants = 0
    @task.save
  end

  def update_remove_assignee(team_membership)
    @task.task_members.where(team_membership_id: team_membership.id).destroy_all
    @task.assignments.where(user_id: team_membership.team_member_id).destroy_all
    @task.number_of_participants -= 1
    @task.save
  end

  def update_add_assignee(membership_id)
    @task.update(
      deadline: @task.created_at + 60.days,
      number_of_participants: @task.try(:number_of_participants).to_i + 1
    )
    @task.send_notification_task_started if @task&.fully_funded_and_enough_teammembers? && @task&.start_doing!
    TaskMember.create(task_id: @task.id, team_membership_id: membership_id)
  end
end
