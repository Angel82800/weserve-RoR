require 'rails_helper'

RSpec.describe TransactionHistory, type: :model do
  xit 'should be created then balance record created' do
    expect(TransactionHistory.count).to be 0
    balance = FactoryGirld.create :balance
    expect(TransactionHistory.count).to be 1
  end
  xit 'expect to have correct values' do
    balance = FactoryGirld.create :balance, amount: 10_000
    expect(balance.transaction_histories.size).to be 1
    transaction = balance.transaction_histories.last
    expect(transaction.entity).to be ''
    expect(transaction.entity_balance).to be ''
    expect(transaction.operation_type).to be ''
    expect(transaction.source).to be ''
    expect(transaction.amount).to be ''
  end
  xit 'should be created then balance updated' do
    balance = FactoryGirld.create :balance, amount: 10_000
    expect(balance.transaction_histories.size).to be 1
    balance.update_attributes(amount: 10_100)
    expect(balance.transaction_histories.size).to be 2
    balance.update_attributes(amount: 9_500)
    expect(balance.transaction_histories.size).to be 3
  end
end
