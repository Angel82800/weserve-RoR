require 'rails_helper'

RSpec.describe Pusher::AuthController do
  let!(:chat_session) { create(:chat_session, uuid: '12345') }
  let!(:requester) { chat_session.requester }
  let!(:receiver) { chat_session.receiver }

  before { sign_in(requester) }

  describe 'POST /pusher/auth' do
    let(:params) { { channel_name: channel_name, socket_id: '12345' } }
    let(:channel_name) { 'private-12345' }

    context 'when requester is allowed to authenticate in a pusher channel' do
      it 'calls the Pusher service with the correct arguments' do
        expect(Pusher).to receive(:authenticate).with('private-12345', '12345')
        post :create, params
        expect(response.status).to eq(201)
      end
    end

    context 'when receiver is allowed to authenticate in a pusher channel' do
      before { sign_in(receiver) }

      it 'calls the Pusher service with the correct arguments' do
        expect(Pusher).to receive(:authenticate).with('private-12345', '12345')
        post :create, params
        expect(response.status).to eq(201)
      end
    end

    context 'when chat session with given channel name does not exists' do
      let(:channel_name) { 'private-98765' }
      before { post :create, params }

      it { expect(response.status).to eq(403) }
    end

    context 'when chat session with given channel name does not exists' do
      before do
        sign_in(create(:user, :confirmed_user))
        post :create, params
      end

      it { expect(response.status).to eq(403) }
    end
  end
end
