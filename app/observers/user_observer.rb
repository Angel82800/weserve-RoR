class UserObserver < ActiveRecord::Observer
  def after_save(user)
    if user.confirmed_at_changed?
      InvitationMailer.welcome_user(user.email).deliver_later
    end
  end
end
