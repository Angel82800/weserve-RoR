require 'rails_helper'

RSpec.describe PayoutTransactionService do
 let(:user) { FactoryGirl.create(:user, confirmed_at: Time.now) }

  describe '#create payout transaction history' do
    it 'create payout transaction history when user is  provided' do
      PayoutTransactionService.create_payout_history({user: user, payout_provider: PayoutTransaction::payout_providers["stripe"], target_account: "test_target_acc",
       transaction_id: "tran_id",status: PayoutTransaction::statuses["completed"], amount: 1000,fee: 29})
      expect(PayoutTransaction.count).to eq(1)
    end
    it 'do not create payout transaction history when user is not provided' do
      PayoutTransactionService.create_payout_history({user: nil, payout_provider: PayoutTransaction::payout_providers["stripe"], target_account: "test_target_acc",
       transaction_id: "tran_id",status: PayoutTransaction::statuses["completed"], amount: 1000,fee: 29})
      expect(TransactionHistory.count).to eq(0)
    end
  end
end
