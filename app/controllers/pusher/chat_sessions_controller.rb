module Pusher
  class ChatSessionsController < ApplicationController
    def create
      chat_session = ChatSession.new(chat_session_params)
      chat_session.requester = current_user
      if chat_session.save
        ChatMailer.invite_receiver(chat_session.requester.id,
                                   chat_session.receiver.id).deliver_later
        render json: chat_session.uuid, status: :created
      else
        render json: chat_session.errors.full_messages,
               status: :unprocessable_entity
      end
    end

    def update
      uuid = params[:channel_name].gsub(/^private-/, '')
      chat_session = ChatSession.find_by_uuid(uuid)
      if chat_session.update(status: params[:status])
        render json: chat_session.uuid, status: :ok
      else
        render json: chat_session.errors.full_messages,
               status: :unprocessable_entity
      end
    end

    private

    def chat_session_params
      params.require(:chat_session).permit(:receiver_id)
    end
  end
end
