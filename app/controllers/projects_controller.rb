class ProjectsController < ApplicationController

  load_and_authorize_resource except: [
    :get_activities, :show_all_revision, :show_all_teams,
    :requests, :donors, :project_admin, :send_project_email, :show_task,
    :send_project_invite_email, :contacts_callback, :read_from_mediawiki,
    :write_to_mediawiki, :revision_action, :revisions, :start_project_by_signup,
    :taskstab, :failure, :get_in, :block_user, :unblock_user, :plan,
    :switch_approval_status, :create_subpage, :rename_subpage, :sub_pages, :rearrange_order_tasks, :rearrange_order_boards,
    :change_leader_by_admin, :change_user_role
  ]

  autocomplete :projects, :title, :full => true
  autocomplete :users, :name, :full => true
  autocomplete :tasks, :title, :full => true
  before_action :set_gon
  before_action :set_project, only: [
    :show, :show_all_teams, :requests, :donors, :taskstab,
    :show_project_team, :edit, :update, :destroy, :save_edits, :update_edits,
    :follow, :rate, :discussions, :read_from_mediawiki, :write_to_mediawiki,
    :revision_action, :revisions, :show_all_revision, :block_user,
    :unblock_user, :plan, :switch_approval_status, :create_subpage, :rename_subpage, :sub_pages,
    :rearrange_order_tasks, :rearrange_order_boards, :change_leader_by_admin, :change_user_role
  ]
  before_action :get_project_user, only: [:show, :taskstab, :show_project_team, :create_subpage]
  skip_before_action :verify_authenticity_token, only: [:rate, :create]
  before_filter :authenticate_user!, only: [:contacts_callback]

  def index
    @change_leader_invitation = ChangeLeaderInvitation.pending.find_by(new_leader: current_user.email) if user_signed_in?
    @featured_projects = Project.where.not(state: "rejected").not_hidden.page params[:page]

    if session[:start_by_signup]
      if session[:start_by_signup] == "true"
        @start_project = true
      elsif session[:start_by_signup] == "false"
        @start_project = false
      end
      session[:start_by_signup] = ''
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def send_project_invite_email
    session[:success_contacts] = nil
    emails = params[:emails].split(',')
    emails.each do |email|
        InvitationMailer.invite_user_for_project(email, current_user.display_name, session[:idd]).deliver_later
    end
    session[:success_contacts] = t('.success')
    session[:project_id] = session[:idd]
    session[:email] = "email-success"
    redirect_to controller: 'projects', action: 'taskstab', id: session[:idd]
  end

  def send_project_email
    respond_to do |format|
      unless params['email'].blank?

        if current_user.blank?
          @notice = t('.fail')
        else

          begin
            domain_error = EmailAddress.error(params['email'])
            unless domain_error
              InvitationMailer.invite_user_for_project(params['email'], current_user.display_name, params['project_id']).deliver_later
              @notice = t('.success', email: params[:email])
            else
              @notice = "#{t('commons.error')}: #{domain_error}"
            end
          rescue => e
            @notice = "#{t('commons.error')}: #{e.message}"
          end
        end
      else
        session[:project_id] = session[:idd]
        @notice = t('.please_provide_email')
      end

      format.html { redirect_to controller: 'projects', action: 'taskstab', id: params['project_id'], notice: @notice }
      format.js {}
    end
  end

  def contacts_callback
    @contacts = request.env['omnicontacts.contacts'].map{|c| c[:email]}.compact
    respond_to do |format|
      format.html
    end
  end

  def failure
    session[:failure_contacts] = nil
    session[:project_id] = session[:idd]
    session[:email_failure] = "failure_email"
    redirect_to controller: 'projects', action: 'taskstab', id: session[:idd]
    session[:failure_contacts] = t('.message')
  end

  def show_task
    @task = Task.find(params[:id])
    @task_comments = @task.task_comments
    @task_attachment = TaskAttachment.new
    @task_attachments = @task.task_attachments
    @task_memberships = @task.team_memberships
    @leader = current_user&.is_coordinator_leader_owner?(@task)
    @assignment = @task.assignments.map(&:user_id).include?(current_user&.id)
    task_comment_ids = @task.task_comments.collect(&:id)
    @activities = Activity.where("(targetable_type= ? AND targetable_id=?) OR (targetable_type= ? AND targetable_id IN (?))", "Task", @task.id, "TaskComment", task_comment_ids).order('created_at DESC')
    @boards = @task.boards_for_select
    @pending_apply_requests = @task.do_requests.pending
    project_admin
    respond_to do |format|
      format.html { redirect_to controller: 'projects', action: 'taskstab', id: @task.project.id, tab: 'tasks', taskId: @task.id }
      format.js
    end

  end

  def autocomplete_user_search
    @results = []
    if params[:term].present?
      projects = Project.fulltext_search(params[:term], 4)
      tasks = Task.fulltext_search(params[:term], 4)
      users = User.fulltext_search(params[:term], 4)

      @results = AutocompleteResultsPresenter.new(projects, tasks, users).results
    end
    respond_to do |format|
      format.html { render partial: 'autocomplete_user_search' }
      format.json { render json: @results.to_json, status: :ok }
    end
  end

  def user_search
    #User search has been disabled because we don't have user's public profile or show page yet available in application we will just add Sunspot.search(Project,Task,User) later
    @results = []

    if params[:title].present?
      # TODO I think here we should have 2 objects projects and tasks, not 1 single result object
      projects = Project.fulltext_search(params[:title])
      tasks = Task.fulltext_search(params[:title])
      users = User.fulltext_search(params[:title])
      @results = [projects, tasks, users].flatten.sort_by do |result|
        (result.try(:title) || result.try(:username) || '').underscore
      end
    end
    respond_to do |format|
      format.html do
        flash.now[:alert] = t('.blank') if @results.blank?
      end
      format.js
    end
  end

  def search_results
    #display solar search results
  end

  def project_admin
    @project_admin = TeamMembership.where("team_id = ? AND state = ?", @task.project.team.id, 'admin').collect(&:team_member_id) rescue nil
  end

  def show
    redirect_to taskstab_project_path(@project)
  end

  def archived
    @featured_projects = Project.only_deleted.page params[:page]
    respond_to do |format|
      format.html
      format.js
    end
  end

  def follow
    if params[:follow] == 'true'
      flash[:alert] = follow_project.errors.full_messages.to_sentence unless @project.follow!(current_user)
    else
      current_user.followed_projects.delete @project
    end
    redirect_to @project
  end

  def unfollow
    project = Project.find params[:id]
    project.unfollow!(current_user)
    flash[:notice] = t('.success', project_title: project.title)
    redirect_to :my_projects
  end

  def rate
    @rate = @project.project_rates.find_or_create_by(user_id: current_user.id)
    @rate.rate = params[:rate]
    @rate.save
    render json: {
        rate: @rate,
        average: @project.rate_avg
    }
  end

  def get_activities
    @task = Task.find(params[:id])
    @activities = @task.activities.order(created_at: :desc).limit(30)

    respond_to :js
  end

  # GET /projects/1/taskstab
  def taskstab
    if session[:email] == "email-success"
      flash.now[:notice] = t('.success')
      session[:email] = nil
    end

    if session[:email_failure] == "failure_email"
      flash[:notice] = t('.fail')
      session[:email_failure] = nil
    end

    @comments, @proj_admins_ids = @project.project_comments.all, @project.proj_admins.ids
    @current_user_id, @rate, @followed = 0, 0, false

    if user_signed_in?
      @available_credit_cards = Payments::StripeSources.new.call(user: current_user)
      @followed = @project.project_users.pluck(:user_id).include? current_user.id
      @current_user_id = current_user.id
      @rate = @project.project_rates.find_by(user_id: @current_user_id).try(:rate).to_i
    end

    @tasks_count = @project.tasks.all.size
    @team_memberships_count = @project.team_memberships_count
    @pending_requests_count = ProjectRequestsService.new(@project).pending_requests_count
    @donors_count = @project.project_donors.count

    @contents, @subpages, @is_blocked = @project.page_info(current_user)

    @histories = get_revision_histories @project
    # if approved_versions?(@histories) == 0
    #   @contents = ''
    # end

    @mediawiki_api_base_url = Project.load_mediawiki_api_base_url

    @apply_requests = @project.apply_requests.pending.all
    @change_leader_invitation = @project.change_leader_invitations.where(:new_leader => current_user.email).first if current_user && @project.change_leader_invitations.where(:new_leader => current_user.email).present?
  end

  def revisions
    authorize! :revisions, @project

    @histories = get_revision_histories @project
    @mediawiki_api_base_url = Project.load_mediawiki_api_base_url

    respond_to do |format|
      format.js
    end
  end

  def switch_approval_status

    authorize! :switch_approval_status, @project

    @histories = get_revision_histories @project
    @mediawiki_api_base_url = Project.load_mediawiki_api_base_url

    if params[:is_approval_enabled].present?
      @project.update_attribute(:is_approval_enabled, params[:is_approval_enabled])

      if @project.is_approval_enabled?
        # Approve latest revision
        @project.approve_revision @histories[0]["revision_id"]
      else
        # Unapprove approved revisions
        @project.unapprove
      end

      @histories = get_revision_histories @project
    end

    respond_to do |format|
      format.js
    end
  end

  def plan
    tasks = @project.tasks.all
    @tasks_count =tasks.count
    @sourcing_tasks = tasks.where(state: "accepted").all
    @mediawiki_api_base_url = Project.load_mediawiki_api_base_url

    @contents, @subpages, @is_blocked = @project.page_info(current_user)

    # @histories = get_revision_histories @project
    # if approved_versions?(@histories) == 0
    #   @contents = ''
    # end

    @apply_requests = @project.apply_requests.pending.all

    respond_to do |format|
      format.html { redirect_to controller: 'projects', action: 'taskstab', id: @project.id, tab: 'plan' }
      format.js
    end
  end

  # POST /projects/1/sub_pages
  def sub_pages
    full_name = params[:mainPageName] + '/' + params[:subPageName]

    subpage_content = @project.read_subpage(full_name).try(:[], 'content')

    respond_to do |format|
      page_status = true
      page_status = false if subpage_content.nil?
      format.json { render json: { page_status: page_status, cnt: subpage_content }, status: :ok }
    end
  end


  def revision_action
    authorize! :revision_action, @project
    if params[:type] == 'approve'
      @project.approve_revision params[:rev]
      users = @project.notifiable_leader_and_coordinators << @project.get_revision_author(params[:rev])
      users.compact.uniq.each do |user|
        NotificationMailer.revision_approved(approver: current_user, project: @project, receiver: user).deliver_later
      end
    elsif params[:type] == 'unapprove'
      @project.unapprove_revision params[:rev]
    end

    redirect_to taskstab_project_path(@project.id), status: :see_other
  end

  def block_user

    authorize! :block_user, @project

    @project.block_user params[:username]
    redirect_to taskstab_project_path(@project.id)
  end

  def unblock_user

    authorize! :unblock_user, @project

    @project.unblock_user params[:username]
    redirect_to taskstab_project_path(@project.id)
  end

  def show_project_team
    respond_to do |format|
      format.js
    end
  end

  def show_all_teams
    respond_to do |format|
      format.html { redirect_to controller: 'projects', action: 'taskstab', id: @project.id, tab: 'team' }
      format.js
    end
  end

  def requests
    requests_service = ProjectRequestsService.new(@project)
    @do_requests = requests_service.pending_do_requests
    @apply_requests = requests_service.pending_apply_requests
    @resolved_do_requests = requests_service.resolved_do_requests
    @resolved_apply_requests = requests_service.resolved_apply_requests
    respond_to { |format| format.js }
  end

  def donors
    @donors = @project.project_donors
    respond_to { |f| f.js }
  end

  def show_all_revision
    @histories = get_revision_histories @project

    respond_to do |format|
      format.js
    end
  end

  def new
    @project = Project.new
  end

  def edit

  end

  def create
    @project = current_user.projects.build(project_params)
    @project.user_id = current_user.id
    if @project.user.admin?
      @project.state = "accepted"
    else
      @project.state = "pending"
    end

    @project.wiki_page_name_from_title

    respond_to do |format|
      if @project.save
        if current_user.username
          # Create new page in wiki and this user will be the owner of this wiki page and project
          @project.page_write current_user, ''
        end

        @project_team = @project.create_team(name: "Team#{@project.id}")
        TeamMembership.create(team_member_id: current_user.id, team_id: @project_team.id, role: 1 )
        current_user.create_activity(@project, 'created')
        Chatroom.create_chatroom_with_groupmembers([current_user], 1, @project)
        format.html { redirect_to @project, notice: t('.request_sent') }
        format.json { render json: {id: @project.slug, status: 200, responseText: t('.success')} }
        session[:project_id] = @project.id
      else
        Rails.logger.debug "Failed to save new project #{@project}"
        format.html { render :new }
        format.json { render json: @project.errors.full_messages.to_sentence, status: :unprocessable_entity }
      end
    end
  end

  def create_subpage
    @project.subpage_write current_user, '', params["title"]
    redirect_to controller: 'projects', action: 'taskstab', id: session[:idd]
  end

  ##
  # Params:
  # id - Project ID
  # subpage_title - Current (old) subpage title (String)
  # new_subpage_title - New subpage title (String)
  def rename_subpage
    authorize! :rename_subpage, @project
    result = @project.subpage_rename(current_user, params[:subpage_title], params[:new_subpage_title])

    if result
      render json: {result: 'ok'}, status: :ok
    else
      render json: {result: 'not modified'}, status: :not_modified
    end
  end

  def update
    authorize! :update, @project

    respond_to do |format|
      old_name = @project.wiki_page_name
      if project_params['title'].present?
        @project.wiki_page_name_from_title project_params['title']
      end
      if @project.update(project_params)
        if old_name != @project.wiki_page_name
          @project.rename_page current_user.username, old_name
        end
        activity = current_user.create_activity(@project, 'updated')
        activity.user_id = current_user.id
        format.html { redirect_to @project, notice: t('.success') }
        format.json { render :show, status: :ok, location: @project }
      else
        flash[:error] = @project.errors.full_messages.join(' - ')
        format.html { redirect_to @project }
        format.json { render :json => @project.errors.full_messages, :status =>:unprocessable_entity }
      end
    end
  end

  def change_leader
    project = Project.find params[:project_id]
    email = params[:leader][:address]
    new_leader = User.find_by(email: email)

    if new_leader.blank?
      flash[:error] = t('.email_not_found')
    elsif project.change_leader_invitations.pending.any?
      flash[:notice] = t('.already_invited')
    elsif !project.team.team_members.include?(new_leader)
      flash[:notice] = t('.cannot_invite_non_team_member')
    elsif email != current_user.email
      invitation = project.change_leader_invitations.create!(new_leader: email, sent_at: Time.current)
      InvitationMailer.invite_leader(invitation.id).deliver_later
      NotificationsService.notify_about_change_leader_invitation(current_user, new_leader, project)
      flash[:notice] = t('.success', email: email)
    end

    redirect_to :my_projects
  end

  def change_leader_by_admin
    authorize! :change_leader_by_admin, @project
    user_assigned = User.find params[:user_id]
    previous_leader = @project.user
    if @project.update(user_id: user_assigned.id)
      team_memberships = @project.team.team_memberships
      set_new_role(team_memberships, previous_leader.id, TeamMembership.roles[:leader], TeamMembership.roles[:teammate])
      if user_has_role_teammate?(team_memberships, user_assigned.id)
        set_new_role(team_memberships, user_assigned.id, TeamMembership.roles[:teammate], TeamMembership.roles[:leader])
      else
        TeamMembership.find_or_create_by(team_member_id: user_assigned.id, team_id: @project.team.id, role: TeamMembership.roles[:leader])
      end

      @project.team.team_members.each do |user|
        NotificationsService.notify_about_leader_change(user, user_assigned, @project)
      end

      NotificationMailer.notify_new_leader_for_project(project: @project, previous_leader: previous_leader).deliver_later
      InvitationMailer.notify_previous_leader_for_new_leader(project: @project, previous_leader: previous_leader).deliver_later
      flash[:notice] = t('.success')
    else
      flash[:alert] = @project.errors.messages.to_s
    end

    redirect_to taskstab_project_path(@project, tab: 'team')
  end

  def change_user_role
    authorize! :change_user_role, @project

    user = User.find params[:user_id]
    role = params[:user][:role]
    user_memberships = @project.team.team_memberships.find_team_members(user.id)

    unless user_memberships.pluck(:role).include? TeamMembership.roles[role]
      if user_memberships.first.update(role: TeamMembership.roles[role])
        flash[:notice] = t('.success')
      else
        flash[:alert] = @project.errors.messages.to_s
      end
    end

    redirect_to taskstab_project_path(@project, tab: 'team')
  end

  # POST /save-edits
  # POST /save-edits.json
  def save_edits
    @project_edit = @project.project_edits.create(description: edit_params[:project_edit])
    @project_edit.user = current_user
    puts @project_edit.description
    respond_to do |format|
      if @project_edit.save
        format.html { redirect_to @project, notice: t('.success') }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_edits
    id_t = params[:project][:editItem][:id]
    new_state = params[:project][:editItem][:new_state]
    puts "id_t: " + id_t
    @project_edit = ProjectEdit.find_by(id: id_t)
    @project_edit.update(:aasm_state => new_state)
    puts @project_edit.description
    if new_state == "accepted"
      @project.description = @project_edit.description
      respond_to do |format|
        if @project.save
          format.html { redirect_to @project, notice: t('.success') }
          format.json { render json: @project, status: :ok }
        else
          format.html { render :edit }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    end

    if new_state == "rejected"
      respond_to do |format|
        if @project.save
          format.html { redirect_to @project, notice: t('.success') }
          format.json { render json: @project, status: :ok }
        else
          format.html { render :edit }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def accept
    @project = Project.find(params[:id])
    if @project.accept!
      activity = current_user.create_activity(@project, 'accepted')
      activity.user_id = current_user.id
      @project.user.update_attribute(:role, 'manager')
      #Change all pending projects for user
      flash[:notice] = t('.success')
    else
      flash[:error] = t('.fail')
    end
    redirect_to current_user
  end

  def reject
    @project = Project.find(params[:id])
    if @project.reject!
      activity = current_user.create_activity(@project, 'rejected')
      activity.user_id = current_user.id
      flash[:success] = t('.success')
    else
      flash[:error] = t('.fail')
    end
    redirect_to current_user
  end

  # this is the action for getting involved in a project
  def get_in
    type = params[:type]
    request_type = type == "0" ? "Lead_Editor" : "Coordinator"
    project = Project.find(params[:id])

    if type == '0' && current_user.is_lead_editor_for?(project)
      flash[:notice] = t('.already_lead_editor')
    elsif type == '1' && current_user.is_coordinator_for?(project)
      flash[:notice] = t('.already_coordinator')
    elsif current_user.has_pending_apply_requests?(project, type)
      flash[:notice] = t('.already_submitted_request')
    else
      RequestMailer.apply_to_get_involved_in_project(applicant: current_user, project: project, request_type: request_type.tr('_', ' ')).deliver_later
      ApplyRequest.create!( user_id: current_user.id,project_id: project.id, request_type: request_type)
      flash[:notice] = t('.success')
    end

    redirect_to project
  end

  def read_from_mediawiki

    @contents = ''
    @mediawiki_api_base_url = Project.load_mediawiki_api_base_url

    if params[:rev]
      @revision_id = params[:rev]
      result = @project.get_revision params[:rev]
      if result
        @contents = result["content"]
      end
    else
      # Get Latest Revision editable
      result = @project.get_latest_revision
      @contents = ''
      if result
        @contents = result
      end
    end

    respond_to do |format|
      format.html { redirect_to controller: 'projects', action: 'taskstab', id: @project.id, tab: 'plan' }
      format.js
    end
  end

  def write_to_mediawiki
    if @project.page_write current_user, params[:data]
      @project.page_read nil
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    authorize! :destroy, @project

    if @project.destroy
      @project.archive(current_user.username)
      activity = current_user.create_activity(@project, 'deleted')
      activity.user_id = current_user.id
      respond_to do |format|
        format.html { redirect_to :my_projects, notice: t('.success') }
        format.json { head :no_content }
      end
    end
  end

  def start_project_by_signup
    session[:start_by_signup] = params[:start_by_signup]
    render json: {
        status: true
    }
  end

  def rearrange_order_tasks
    authorize! :rearrange_order_tasks, @project
    begin_sortable('task', params[:tasks_order])
    render json: {status: 200}
  end

  def rearrange_order_boards
    authorize! :rearrange_order_boards, @project
    boards_ids = params[:boards_order].reject { |c| c.empty? }
    begin_sortable('board',boards_ids)
    render json: {status: 200}
  end

  private
  # rearrange order of tasks or boards via priority
  def begin_sortable(klass_name, order_arr)
    klass = klass_name.classify.constantize
    klass.transaction do
      order_arr.each_with_index do |id, value|
        t = klass.find id
        priority = value + 1
        t.update_attribute('priority', priority)
      end
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    if user_signed_in? && current_user.admin?
      @project = Project.with_deleted.find(params[:id])
    else
      begin
        @project = Project.not_hidden.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to :projects
      end
    end

  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(
        :title, :short_description, :institution_country, :description, :country,
        :picture, :user_id, :institution_location, :state, :expires_at, :request_description,
        :institution_name, :institution_logo, :institution_description, :section1, :section2,
        :picture_crop_x, :picture_crop_y, :picture_crop_w, :picture_crop_h,
        :parent_id, project_edits_attributes: [:id, :_destroy, :description]
    )
  end

  def get_project_user
    @project_user = @project.user
  end

  def edit_params
    params.require(:project).permit(:id, :project_edit, :editItem)
  end

  # Get revision histories
  def get_revision_histories project
    result = project.get_history
    @histories = []

    if result
      result.each do |r|
        history                = Hash.new
        history["revision_id"] = r["id"]
        history["datetime"]    = DateTime.strptime(r["timestamp"],"%s").strftime("%l:%M %p %^b %d, %Y")
        history["user"]        = User.find_by_username(r["author"][0].downcase+r["author"][1..-1]) || User.find_by_username(r["author"])
        history["status"]      = r['status']
        history["comment"]     = r['comment']
        history["username"]    = r["author"]
        history["is_blocked"]  = r["is_blocked"]

        @histories.push(history)
      end
      return @histories
    else
      return []
    end
  end

  # Get status if there are approved versions or not
  def approved_versions? histories
    flg = 0

    histories.each do |history|
      if history["status"] == "approved"
        flg = 1
        break
      end
    end

    return flg
  end

  def set_gon
    @short_descr_limit = gon.short_descr_limit = Project::SHORT_DESCRIPTION_LIMIT
  end

  def set_new_role(team_memberships, user_id, old_role, new_role)
    team_memberships.find_team_members(user_id).where(role: old_role).each { |member| member.update(role: new_role) }
  end

  def user_has_role_teammate?(team_memberships, user_id)
    team_memberships.find_team_members(user_id).pluck(:role).include?(0)
  end
end
