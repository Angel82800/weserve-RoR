require 'rails_helper'

RSpec.describe CreateTransactionHistoryService do
 let(:user1) { FactoryGirl.create(:user, confirmed_at: Time.now) }
 let(:user2) { FactoryGirl.create(:user, confirmed_at: Time.now) }
 let(:task) { FactoryGirl.create(:task) }

 describe '#create transaction history' do
    it 'create transaction history when source and destination is provided for user' do
      CreateTransactionHistoryService.update_amount(120, user1, user2 )
      expect(TransactionHistory.count).to eq(2)
    end
    it 'create transaction history when source and destination is provided for task' do
      CreateTransactionHistoryService.update_fund(user1, task, 120)
      expect(TransactionHistory.count).to eq(2)
    end
  end
end
