require 'rails_helper'

feature 'Main page popups' do
  scenario 'when anonymous user visits', js: true do
    visit root_path

    find(".auth_links .sign_up_a").trigger("click")

    modal = find('div#registerModal', visible: true)

    expect(modal).to be_visible

    expect(modal).to have_link I18n.t('commons.sign_in_with_gplus')
    expect(modal).to have_link I18n.t('commons.sign_in_with_fb')
    expect(modal).to have_link I18n.t('commons.sign_in_with_twitter')

    expect(modal).to have_field 'user_username'
    expect(modal).to have_field 'user_email'
    expect(modal).to have_field 'user_password'
    expect(modal).to have_field 'user_password_confirmation'
    expect(modal).to have_button 'Sign up'
  end

  scenario 'Projects page is working for anonymous user', js: true do
    visit '/'

    find('.header .project_navi ._active-project').click

    expect(page).to have_current_path(projects_path, only_path: true)
  end
end
