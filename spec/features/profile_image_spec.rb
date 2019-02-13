require 'rails_helper'

feature "Profile Image", js: true do
  before do
    @users = FactoryGirl.create_list(:user, 2, confirmed_at: Time.now)
    @user = @users.first
    @another_user = @users.last
  end
end
