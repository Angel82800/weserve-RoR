require 'rails_helper'

feature 'Wallet page working correctly', type: :feature, js: true do

  before do
    @user = FactoryGirl.create(:user)
    @user.confirmed_at = Time.now
    @user.save
  end

  let(:email) { @user.email }
  let(:password) { @user.password }

  scenario 'Website is working or not' do
    visit '/'
    page.status_code == '200'
  end

  scenario 'Going to random page on site' do
    visit projects_path

    expect(page).to have_link(I18n.t('commons.active_projects'))
    expect(page).to have_text(I18n.t('projects.index.title'))
  end

  scenario 'Must be redirected to landing page when clicking logo on site' do
    visit projects_path

    home_link = find(".custom_logo a", visible: true)
    home_link.click
    expect(page).to have_current_path(root_path)
  end

  scenario 'logging in with email' do
    visit root_path
    find(".auth_links .sign_in_a").trigger("click")
    modal = find('div#registerModal', visible: true)
    sign_in_form = modal.find('._sign-in#sign_in_show')

    sign_in_form.fill_in 'session_email', with: email
    sign_in_form.fill_in 'session_password', with: password
    sign_in_form.click_button 'Sign in'

    expect(page).to have_current_path(root_path)
  end

  scenario 'User logged in goes to random page on site' do
    visit projects_path

    expect(page).to have_link(I18n.t('commons.active_projects'))
    expect(page).to have_text(I18n.t('projects.index.title'))
  end

  scenario 'Must be redirected to home page when clicking logo on site' do
    visit projects_path

    home_link = find(".custom_logo a", visible: true)
    home_link.click
    expect(page).to have_current_path(root_path)
  end
end
