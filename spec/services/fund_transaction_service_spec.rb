require 'rails_helper'

RSpec.describe FundTransactionService do
 let(:user) { FactoryGirl.create(:user, confirmed_at: Time.now) }
 let(:task) { FactoryGirl.create(:task) }
 let(:amount) { 10000 }

 describe '#fund transaction service' do
    it 'add/deduct balance to/from user and the user balance doesn\'t change' do
    	old_balance = user.current_balance
      FundTransactionService.perform_post_operation(task, user, amount)
      comm_obj = CommissionCalculation.new(amount, user)
      amt = comm_obj.amount_after_fee
      expect(user.current_balance).to eq(old_balance)
    end
    it 'update task balance' do
      FundTransactionService.perform_post_operation(task, user, amount)
      comm_obj = CommissionCalculation.new(amount, user)
      amt = comm_obj.amount_after_fee
      expect(task.current_fund).to eq(amount)
      expect(task.current_amount).to eq(amt)
    end
    it 'create 4 transaction histories' do
      FundTransactionService.perform_post_operation(task, user, amount)
      expect(TransactionHistory.count).to eq(2)
    end
  end
end
