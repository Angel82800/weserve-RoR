require 'rails_helper'

feature "Forgot Password", js: true do
  before do
    visit root_path
  end

  context "When you click 'LOGIN' link" do
    before do
      @user = FactoryGirl.create(:user)

      find(".auth_links .sign_in_a").trigger("click")

      @modal = find('div#registerModal', visible: true)
    end

    scenario "Then the Sign In modal appeared" do
      expect(@modal).to be_visible
    end

    context "When you click 'Forgot password?' link" do
      before do
        click_pseudo_link 'Forgot password?'
      end

      scenario "Then you are redirected to the Forgot Password page" do
        expect(page).to have_current_path(new_user_password_path)
      end

      context "When you fill your email and click 'Reset Password' button" do
        before do
          find(".forgot-pwd-form #new_user").fill_in 'user[email]', with: @user.email

          find(".forgot-pwd-form #new_user .btn-default-weserve").click
        end

        scenario "Then the password instruction has been sent to you" do
          last_delivery = ActionMailer::Base.deliveries.last
          expect(last_delivery.to.first).to eq(@user.email)
        end
      end
    end
  end
end
