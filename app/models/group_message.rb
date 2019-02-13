class GroupMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :chatroom
  has_many :user_message_read_flags, dependent: :destroy

  validates :message,presence: true, unless: :attachment?
  validates :chatroom, presence: true

  # Tells rails to use this uploader for this model.
  mount_uploader :attachment, AttachmentUploader

  def create_user_message_read_flags_for_all_groupmembers_except(user)
    chatroom.users.where.not(id: user.id).each do |chatroom_user|
      if chatroom_user.online?
        user_message_read_flags.create(read_status: false, user: chatroom_user)
      else
        NotificationMailer.new_message(id, chatroom_user.id).deliver_later
      end
    end
  end
end
