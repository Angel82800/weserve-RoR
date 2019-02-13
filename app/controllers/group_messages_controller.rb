class GroupMessagesController < ApplicationController
  autocomplete :user, :username, :full => true, :display_value => :search_display_results
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!
  before_action :set_group_message, only: [:show, :edit, :update, :destroy]
  before_action :validate_create_messages_access_for_chatroom, only: [:create]

  layout 'dashboard', only: [:index, :get_chatroom]

#-------------------------------------------------------------------------------
# Standard Controller Actions
#-------------------------------------------------------------------------------

  def index
    @user_projects = current_user.get_users_projects_and_team_projects

    if params[:user_id].present?
      @chatroom, @group_messages = Chatroom.get_or_create_dm_chatroom_group_messages(current_user, User.find(params[:user_id]))
    else
      if @user_projects.any?
        @chatroom, @team_memberships, @group_messages =
          Chatroom.get_or_create_project_chatroom_team_memberships_group_messages(
            @user_projects.first, current_user
          )
        @team_memberships = current_user.projects_team_memberships
      else
        @group_messages = []
      end
    end

    @chatroom.mark_all_chatroom_messages_as_read_for(current_user) if @chatroom.present?
    @dm_chatroom_users = current_user.all_dm_chatroom_users
  end

  def show
  end

  def new
    @group_message = GroupMessage.new
  end

  def create
    @group_message = GroupMessage.new(group_message_params)
    @group_message.user = current_user
    if @group_message.save
      @group_message.create_user_message_read_flags_for_all_groupmembers_except(current_user)
    else
      @notice = t('.fail', allowed_types: AttachmentUploader::SUPPORTED_FILE_EXTENSIONS.join(', '))
    end
    respond_to { |f| f.js }
  end

  def update
    respond_to do |format|
      if @group_message.update(group_message_params)
        format.json { render :show, status: :ok, location: @group_message }
      else
        format.json { render json: @group_message.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @group_message.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

#-------------------------------------------------------------------------------
# API
#-------------------------------------------------------------------------------

  def get_chatroom

    project = Project.find(params[:project_id]) if params[:project_id].present?
    if params[:user_id].present?
      recipient_user = User.find(params[:user_id])
      @chat_sessions = ChatSession.for_users(current_user, recipient_user)
    else
      @chat_sessions = ChatSession.for_users(current_user)
    end

    if project.present? && !recipient_user.present?
      #Project Chatroom visible to all team members
      @chatroom, @team_memberships, @group_messages = Chatroom.get_or_create_project_chatroom_team_memberships_group_messages(project, current_user)

    elsif project.present? && recipient_user.present?
      #Project Direct Message between Project Team Members
      @chatroom, @group_messages = Chatroom.get_or_create_project_dm_chatroom_group_messages(project, current_user, recipient_user)

    elsif !project.present? && recipient_user.present?
      #Direct Message between any users, not attached to a project
      @chatroom, @group_messages = Chatroom.get_or_create_dm_chatroom_group_messages(current_user, recipient_user)

    end

    @dm_chatroom_users = current_user.all_dm_chatroom_users

    if @chatroom.present?
      @chatroom.mark_all_chatroom_messages_as_read_for(current_user)
      respond_to :js
    else
      redirect_to group_messages_path
    end

  end

  def refresh_chatroom_messages
    chatroom = Chatroom.find(params[:id])
    if chatroom.present? && chatroom.validate_access_for(current_user)
      @group_messages = GroupMessage.where(chatroom_id: params[:id]).last(25)
      chatroom.mark_all_chatroom_messages_as_read_for(current_user)
      respond_to :js
    end
  end

  def search_user
    @user = current_user
    if params[:search]
      @user = User.name_like("%#{params[:search]}%").order('username')
    end
  end

  def download_files
    group_message = GroupMessage.find(params[:id])
    if Chatroom.validate_access_from_params(group_message.chatroom_id,current_user)
      if group_message.attachment.blank?
        redirect_to group_messages_path
      else
        data = open(group_message.attachment.url)
        send_data data.read, filename:group_message.attachment.file.filename, stream: 'true'
      end
    else
      redirect_to group_messages_path
    end
  end

#-------------------------------------------------------------------------------

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group_message
    @group_message = GroupMessage.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def group_message_params
    params.require(:group_message).permit(:message, :user_id, :chatroom_id, :attachment)
  end

  def validate_create_messages_access_for_chatroom
    Chatroom.validate_access_from_params(params['group_message']['chatroom_id'], current_user)
  end

end
