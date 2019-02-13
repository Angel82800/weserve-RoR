require 'rails_helper'

RSpec.describe ChatSession, type: :model do
  it { is_expected.to belong_to(:requester).class_name('User') }
  it { is_expected.to belong_to(:receiver).class_name('User') }

  it { is_expected.to validate_presence_of(:requester) }
  it { is_expected.to validate_presence_of(:receiver) }

  let(:chat_session) { create(:chat_session) }
  let(:requester) { chat_session.requester }
  let(:receiver) { chat_session.receiver }

  describe 'callbacks' do
    describe '.initial_values' do
      before do
        allow(SecureRandom).to receive(:uuid).and_return('12345', '67890')
      end
      it { expect(chat_session.status).to eq 'pending' }
      it { expect(chat_session.uuid).to eq '12345' }

      context 'trying to create a chat session with the same uuid' do
        let!(:chat_session2) { create(:chat_session, uuid: '12345') }

        it { expect(chat_session.uuid).to eq '67890' }
      end
    end
  end

  describe '.participating_user?' do
    subject { chat_session.participating_user?(user) }

    context 'requester' do
      let(:user) { requester }
      it { is_expected.to be_truthy }
    end

    context 'receiver' do
      let(:user) { receiver }
      it { is_expected.to be_truthy }
    end

    context 'another user' do
      let(:user) { create(:user) }
      it { is_expected.to be_falsey }
    end
  end

  describe '.for_users' do
    subject { ChatSession.for_users(*users) }

    context 'for a single user' do
      let(:users) { requester }
      it { is_expected.to include chat_session }
    end

    context 'for multiple users' do
      let(:users) { [requester, receiver] }
      it { is_expected.to include chat_session }
    end
  end
end
