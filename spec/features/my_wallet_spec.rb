require 'rails_helper'
include ApplicationHelper

feature 'My Wallet', js: true do

  context 'As logged in user' do
    let(:users) { create_list(:user, 2, :confirmed_user, :with_balance) }
    let(:current_user) { users[0] }
    let(:source_user)  { users[1] }

    before do
      login_as(current_user, :scope => :user, :run_callbacks => false)
    end

    context 'When you visit the Home page and the click your name link' do
      before do
        visit '/'
        find('a.pr-user').trigger('click')

        @dropdown = find('ul.dropdown-menu')
      end

      scenario "Then you can see the 'My Profile' link in the top right dropdown menu" do
        expect(@dropdown).to be_visible
      end

      context 'when you open my wallet page' do
        before do
          current_user.reload
        end

        context "When you click the 'My Wallet' and you have transactions" do

          before do
            @transactions = create_list(:transaction_history, 2, tran_record: current_user, source: source_user, operation_type: 'debit')

            VCR.use_cassette('coinbase/wallet_transactions_present') do
              @dropdown.click_link 'My Wallet'
            end
          end

          scenario 'Then you are redirected to the profile page' do
            expect(page).to have_current_path(my_wallet_user_path(current_user))
          end

          scenario 'Then you can see the user balance' do
            expect(page).to have_content "#{I18n.t('commons.balance')}: #{ENV['symbol_currency']}#{balance_in_usd(current_user.balance.amount)} #{ENV['currency']}"
          end

          scenario 'And you see a list of transactions' do
            expect(page).to have_selector(".t-transactions__row", count: 3)
          end
        end

        context "When you click the 'My Wallet' with no transactions" do
          before do
            VCR.use_cassette('coinbase/wallet_transactions_empty') do
              @dropdown.click_link 'My Wallet'
            end
          end

          scenario 'Then you are redirected to the profile page' do
            expect(page).to have_current_path(my_wallet_user_path(current_user))
          end

          scenario 'And you see a message that there is no transactions' do
            expect(page).to have_content(I18n.t('users.user_transactions.no_transaction'))
          end
        end
      end
    end
  end
end
