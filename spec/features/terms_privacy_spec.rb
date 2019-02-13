require 'rails_helper'

feature 'Terms and Privacy pages ' do
  scenario 'user should be redirected to Privacy Policy page when click the link ', js: true do
    visit root_path
    page.find('.footer .privacy-policy').click
    expect(page).to have_current_path(pages_privacy_policy_path)
  end

  scenario 'user should be redirected to Terms of Use page when click the link ', js: true do
    visit root_path
    page.find('.footer .term-of-use').click
    expect(page).to have_current_path(pages_terms_of_use_path)
  end
end
