class TaskAttachment < ActiveRecord::Base
  belongs_to :task

  validates :task_id, presence: true
  validates :attachment, presence: true

  mount_uploader :attachment, AttachmentUploader # Tells rails to use this uploader for this model.
end
