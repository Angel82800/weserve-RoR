class ConfirmationsController < Devise::ConfirmationsController
  include Mediawiki
  # We use this to autologin user when they confirm their email, although Devise does not recommend this behaviour
  def show
    super do |resource|
      sign_in(resource)
      set_cookies resource
    end
  end

  private
  def after_confirmation_path_for(*)
    path = session["user_return_to"]
    session.delete("user_return_to")
    path || root_path
  end
end
