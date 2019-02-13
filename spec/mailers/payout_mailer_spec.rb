require 'rails_helper'

RSpec.describe PayoutMailer, type: :mailer do
  let(:receiver) { FactoryGirl.create(:user, email: Faker::Internet.email, confirmed_at: Time.now) }
  let(:amount) { 114624 }
  let(:mailjet_variables) {
    {
        "ReceiverName" => receiver.display_name,
        "Amount" => 1146.24,
        "CurrencySymbol" => ENV['symbol_currency']
    }
  }

  describe '#request_withdrawal' do
    subject(:email) { described_class.request_withdrawal(amount, receiver).deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(receiver.email)
    end

    it_behaves_like 'mailjet api email'
  end

  describe '#finished_withdrawal' do
    subject(:email) { described_class.finished_withdrawal(amount, receiver, "in_transit").deliver_now }

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(receiver.email)
    end

    it_behaves_like 'mailjet api email'
  end
end
