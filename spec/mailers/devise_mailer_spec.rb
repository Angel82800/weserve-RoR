require "rails_helper"

RSpec.describe DeviseMailer, type: :mailer do
  include Devise::Controllers::UrlHelpers
  describe '#confirmation_instructions' do
    subject(:email) do
      described_class.confirmation_instructions(record, token, {}).deliver_now
    end

    let(:record) { build(:user, :confirmed_user, first_name: 'Homer', last_name: 'Simpson') }
    let(:token) { 'asdfwefwere' }

    it 'has the correct To e-mail' do
      expect(email.to.first).to eq(record.email)
    end

    it_behaves_like 'mailjet api email'
  end

  describe '#reset_password_instructions' do
    subject(:email) do
      described_class.reset_password_instructions(record, token, {}).deliver_now
    end

    let(:record) { build(:user, :confirmed_user, first_name: 'Homer', last_name: 'Simpson') }
    let(:token) { 'asdfwefwere' }

    it 'has the correct To e-mail' do
      expect(email.to.first).to eq(record.email)
    end

    it_behaves_like 'mailjet api email'
  end
end
