require 'rails_helper'

RSpec.describe Pusher::MessagesController do
  let!(:chat_session) { create(:chat_session, uuid: '12345') }
  let!(:requester) { chat_session.requester }
  let!(:receiver) { chat_session.receiver }

  before { sign_in(requester) }

  describe 'POST /pusher/messages' do
    let(:params) do
      { channel: channel_name, message: 'A new message', socket_id: '12345' }
    end
    let(:channel_name) { 'private-12345' }

    context 'when requester is allowed to authenticate in a pusher channel' do
      it 'calls the Pusher service with the correct arguments' do
        expect(Pusher).to receive(:trigger).with('private-12345', 'message',
                                                 'A new message', '12345')
        post :create, params
        expect(response.status).to eq(201)
      end
    end

    context 'when receiver is allowed to authenticate in a pusher channel' do
      before { sign_in(receiver) }

      it 'calls the Pusher service with the correct arguments' do
        expect(Pusher).to receive(:trigger).with('private-12345', 'message',
                                                 'A new message', '12345')
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
