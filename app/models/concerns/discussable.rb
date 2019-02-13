module Discussable
  extend ActiveSupport::Concern

  included do
    has_many :discussions, as: :discussable, dependent: :destroy, autosave: true
  end

  def discussion_content user, field_name
    self.discussions.of_field(field_name).of_user(user)
  end

  def filtered_discussions(usr)
    usr.is_admin_for?(self) ? discussions : discussions.of_user(usr)
  end

  def can_update?
    true
  end

end