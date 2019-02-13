require 'rails_helper'

feature 'Sign-in popup displaying correctly', type: :feature, js: true do
  scenario 'Website is working or not' do
    visit '/'
    page.status_code == '200'
  end

  scenario 'Anonymous user should see sign-in modal on home page' do
    visit root_path
    # expect(page).to have_text('Turn your followers into a task force')

    find(".auth_links .sign_in_a").trigger("click")

    modal = find('div#registerModal', visible: true)
    expect(modal).to be_visible

    expect(modal).to have_link I18n.t('commons.sign_in_with_gplus')
    expect(modal).to have_link I18n.t('commons.sign_in_with_twitter')
    expect(modal).to have_link I18n.t('commons.sign_in_with_fb')

    expect(modal).to have_field 'user_username'
    expect(modal).to have_field 'user_email'
    expect(modal).to have_field 'user_password'
    expect(modal).to have_field 'user_password_confirmation'
    expect(modal).to have_button I18n.t('commons.sign_in')
  end
end
