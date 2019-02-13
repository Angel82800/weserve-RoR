class Wiki < ActiveRecord::Base
  include AASM

  default_scope -> { order('created_at DESC') }

  belongs_to :project

  acts_as_paranoid

  mount_uploader :pictureone, PictureUploader
  mount_uploader :picturetwo, PictureUploader
  mount_uploader :picturethree, PictureUploader
  mount_uploader :picturefour, PictureUploader
  mount_uploader :picturefive, PictureUploader

  aasm :column => 'state', :whiny_transitions => false do
    state :pending
    state :accepted
    state :rejected
  end
end
