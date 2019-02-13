require 'rails_helper'

feature 'Transation Histories', js: true do
  let(:dropdown) { find('ul.dropdown-menu') }

  before do
    login_as(current_user, scope: :user, run_callbacks: false)

    visit '/'
    find('a.pr-user').trigger('click')
  end

  context 'As non admin user' do
    let(:current_user) { create(:user, confirmed_at: Time.now) }

    context 'When you visit the Home page and the click your name link' do
      scenario 'Then you can opened dropdown menu below user name' do
        expect(dropdown).to be_visible
      end

      scenario 'When you sign in as not site admin' do
        expect(dropdown).not_to have_content(I18n.t('commons.full_history'))
      end
    end
  end

  context 'As admin user' do
    let(:current_user) { create(:user, confirmed_at: Time.now, admin: true) }

    context 'When you visit the Home page and the click your name link' do
      scenario 'Then you can opened dropdown menu below user name' do
        expect(dropdown).to be_visible
      end

      scenario 'When you see links for admin' do
        expect(dropdown).to have_content(I18n.t('commons.full_history'))
      end

      context 'When you sign ap as site admin' do
        before do
          dropdown.click_link I18n.t('commons.full_history')
        end

        scenario "And you don't see transactions histories list" do
          expect(page).to have_content(I18n.t('users.user_transactions.no_transaction'))
        end

      end

      context 'When you have transaction histories' do
        let!(:histories) { create_list(:transaction_history, 2) }
        before do
          dropdown.click_link I18n.t('commons.full_history')
        end

        scenario "And you don't see transactions histories list" do
          expect(page).to have_selector('.t-transactions__row', count: 3)
        end
      end
    end
  end
end
