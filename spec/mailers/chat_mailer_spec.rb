require "rails_helper"

RSpec.describe ChatMailer, type: :mailer do
  describe '#invite_receiver' do
    subject(:email) do
      described_class.invite_receiver(requester.id, receiver.id).deliver_now
    end
    let!(:requester) { create(:user, :confirmed_user, first_name: 'Homer', last_name: 'Simpson') }
    let!(:receiver) { create(:user, :confirmed_user) }

    it 'sends an email' do
      expect { email }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(receiver.email)
    end
  end

  describe '#send_summary' do
    subject(:email) do
      described_class.send_summary(receiver.id).deliver_now
    end
    let!(:receiver) { create(:user, :confirmed_user) }

    it 'sends an email' do
      expect { email }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'has the correct receiver email address' do
      expect(email.to.first).to eq(receiver.email)
    end
  end
end
