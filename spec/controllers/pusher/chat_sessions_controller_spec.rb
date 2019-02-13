require 'rails_helper'

RSpec.describe Pusher::ChatSessionsController do
  let!(:requester) { create(:user, :confirmed_user) }
  let!(:receiver) { create(:user, :confirmed_user) }

  before { sign_in(requester) }

  describe 'POST /pusher/chat_sessions' do
    let(:params) { { chat_session: { receiver_id: receiver_id } } }
    let(:receiver_id) { receiver.id }
    let(:channel_name) { 'private-12345' }
    before { post :create, params }

    context 'when parameters are valid' do
      it { expect(response.status).to eq(201) }
      it { expect(ChatSession.count).to eq(1) }
    end

    context 'when receiver do not exist' do
      let(:receiver_id) { 'asdf' }
      it { expect(response.status).to eq(422) }
    end
  end

  describe 'PUT /pusher/chat_sessions' do
    let!(:chat_session) { create(:chat_session, uuid: uuid) }
    let(:uuid) { '12345' }
    before { put :update, channel_name: "private-#{uuid}", status: :connected }

    context 'when parameters are valid' do
      it { expect(response.status).to eq(200) }
      it { expect(chat_session.reload.status).to eq('connected') }
    end
  end
end
