require 'rails_helper'

feature 'Register popup displaying correctly', type: :feature, js: true do
  scenario 'Website is working or not' do
    visit '/'
    page.status_code == '200'
  end

  scenario 'Anonymous user should see register modal on home page' do
    visit root_path
    # expect(page).to have_text(I18n.t('landing.hero-title'))

    find(".auth_links .sign_up_a").trigger("click")

    modal = find('div#registerModal', visible: true)
    expect(modal).to be_visible

    expect(modal).to have_link I18n.t('commons.sign_up_with_gplus')
    expect(modal).to have_link I18n.t('commons.sign_up_with_twitter')
    expect(modal).to have_link I18n.t('commons.sign_up_with_fb')

    expect(modal).to have_field 'user_username'
    expect(modal).to have_field 'user_email'
    expect(modal).to have_field 'user_password'
    expect(modal).to have_field 'user_password_confirmation'
    expect(modal).to have_button I18n.t('devise.registrations.new.sign_up')
  end
end
