require 'rails_helper'

def include_failed_sign_up_scenarios
  scenario "You have not been registered" do
    expect(User.count).to eq @before_count
  end

  scenario "You've had to see the Signup modal window" do
    expect(page).to have_selector('#sign_up_show')
  end

  scenario "You should stay on the same page" do
    expect(page).to have_current_path(root_path, only_path: true)
  end
end

feature 'Normal Sign up', js: true do
  before do
    visit root_path
    find(".auth_links .sign_up_a").trigger("click")

    @modal = find('div#registerModal', visible: true)
  end

  context "When click 'Register' link" do
    scenario "Sign up popup appeared" do
      expect(@modal).to be_visible
    end

    context "When fill the fields and click 'Sign Up' button", vcr: { cassette_name: 'coinbase/wallet_creation' } do
      before do
        @user = FactoryGirl.build(:user, :with_password_confirmation)

        @before_count = User.count

        sign_up_form = @modal.find('#sign_up_show')
        submit_sign_up_form(sign_up_form, @user)
      end

      scenario "You have been registered" do
        expect(page).to have_text I18n.t 'devise.registrations.signed_up_but_unconfirmed'
        expect(User.count).not_to eq @before_count
      end

      scenario "You have been redirected to the 'Active Projects' page" do
        expect(page).to have_current_path(home_index_path, only_path: true)
      end

      scenario "Successful registration message appeared" do
        expect(page).to have_text I18n.t 'devise.registrations.signed_up_but_unconfirmed'
      end

      scenario "Confirmation email has been sent to you" do
        last_delivery = ActionMailer::Base.deliveries.last
        expect(last_delivery.to.first).to eq(@user.email)
      end
    end

    context "When fill the fields with incorrect data and click 'Sign Up' button", vcr: { cassette_name: 'coinbase/wallet_creation' } do
      before do
        @user = FactoryGirl.build(:user, :with_password_confirmation)
        @before_count = User.count
        @sign_up_form = @modal.find('#sign_up_show')
      end

      context "When email is blank" do
        before do
          submit_sign_up_form(@sign_up_form, @user, except: %w(email))
        end

        include_failed_sign_up_scenarios

        scenario "You have had to see the validation errors" do
          expect(find('#user_email.register-form__email')[:required]).to be true
        end

        scenario " You've had to see the input data which was filled in" do
          expect(find('#user_username.register-form__username').value).to eq(@user.username)
        end
      end

      context "When email does not contain '@' symbol" do
        before do
          submit_sign_up_form(@sign_up_form, @user, except: %w(email)) do |form|
            form.fill_in 'user_email', with: 'incorrect_email.com'
          end
        end

        include_failed_sign_up_scenarios
      end

      context "When username is blank" do
        before do
          submit_sign_up_form(@sign_up_form, @user, except: %w(username))
        end

        include_failed_sign_up_scenarios
      end

      context "When password is blank" do
        before do
          submit_sign_up_form(@sign_up_form, @user, except: %w(password))
        end

        include_failed_sign_up_scenarios
      end

      context "When password_confirmation is blank" do
        before do
          submit_sign_up_form(@sign_up_form, @user, except: %w(password_confirmation))
        end

        include_failed_sign_up_scenarios
      end

      context "When password_confirmation does not match password" do
        before do
          submit_sign_up_form(@sign_up_form, @user, except: %w(password_confirmation)) do |form|
            form.fill_in 'user_password_confirmation', with: 'wrong-wrong'
          end
        end

        include_failed_sign_up_scenarios
      end
    end
  end
end
