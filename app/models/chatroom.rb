class Chatroom < ActiveRecord::Base
  belongs_to :project
  has_many :groupmembers, dependent: :destroy
  has_many :users, -> { uniq }, through: :groupmembers
  has_many :group_messages, dependent: :destroy
  has_many :user_message_read_flags, :through => :group_messages

  scope :project_chatrooms, -> { where(chatroom_type: 1) }
  scope :project_dm_chatrooms, -> { where(chatroom_type: 2) }
  scope :dm_chatrooms, -> { where(chatroom_type: 3) }

#-------------------------------------------------------------------------------
# Class Methods
#-------------------------------------------------------------------------------

  def self.create_chatroom_with_groupmembers(groupmembers, chatroom_type, project=nil)
    if project.present?
      chatroom = project.chatrooms.create(chatroom_type: chatroom_type)
    else
      chatroom = Chatroom.create(chatroom_type: chatroom_type)
    end

    groupmembers.each do |groupmember|
      chatroom.groupmembers.create(user_id: groupmember.id)
    end

    return chatroom
  end


  def self.get_or_create_project_chatroom_team_memberships_group_messages(project, current_user)
    chatroom = project.chatrooms.project_chatrooms.first
    if chatroom.present? && chatroom.validate_access_for(current_user)
      group_messages = chatroom.group_messages
    else
      if current_user.is_project_team_member?(project)
        chatroom = Chatroom.create_chatroom_with_groupmembers(project.team_members, 1, project)
        group_messages = []
      end
    end

    team_memberships = project.all_team_memberships_except(current_user)

    return chatroom, team_memberships, group_messages
  end

  def self.get_or_create_project_dm_chatroom_group_messages(project, current_user, recipient_user)
    chatroom = (current_user.chatrooms.project_dm_chatrooms.where(project: project) & recipient_user.chatrooms.project_dm_chatrooms.where(project: project)).first
    if chatroom.present?
      group_messages = chatroom.group_messages
    else
      if current_user.is_project_team_member?(project)
        chatroom = Chatroom.create_chatroom_with_groupmembers([current_user, recipient_user], 2, project)
        group_messages = []
      end
    end

    return chatroom, group_messages
  end

  def self.get_or_create_dm_chatroom_group_messages(current_user, recipient_user)
    chatroom = (current_user.chatrooms.dm_chatrooms & recipient_user.chatrooms.dm_chatrooms).first
    if chatroom.present?
      group_messages = chatroom.group_messages
    else
      chatroom = Chatroom.create_chatroom_with_groupmembers([current_user, recipient_user], 3)
      group_messages = []
    end

    return chatroom, group_messages
  end


  def self.validate_access_from_params(chatroom_id, current_user)
    chatroom = Chatroom.find(chatroom_id)
    chatroom.validate_access_for(current_user) if chatroom.present?
  end

  def self.add_user_to_project_chatroom(project, user_id)
    project_chatroom = project.get_project_chatroom
    project_chatroom.groupmembers.create(user_id: user_id) if project_chatroom.present?
  end

  def self.remove_user_from_project_chatroom(project, user)
    project_chatroom = project.get_project_chatroom
    if project_chatroom.present?
      users_groupmember = project_chatroom.groupmembers.where(user: user).first
      users_groupmember.destroy if users_groupmember.present?
    end
  end


#-------------------------------------------------------------------------------
# Instance Methods
#-------------------------------------------------------------------------------

  def get_other_messaging_user(current_user)
    self.groupmembers.where.not(user: current_user).first.user
  end

  def get_display_title
    case self.chatroom_type
    when 1
      #Project Group Chatroom
      self.project.title
    when 2
      #Direct Message to a Project Team Member
      "#{self.project.title} - Conversation with "
    when 3
      #Direct Message with no Project
      "Conversation with "
    end
  end

  def validate_access_for(current_user)
    (self.groupmembers & current_user.groupmembers).any?
  end

  def mark_all_chatroom_messages_as_read_for(user)
    self.user_message_read_flags.where(user: user).update_all(read_status: true, updated_at: DateTime.now)
  end

#-------------------------------------------------------------------------------

end
