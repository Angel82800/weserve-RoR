module Pusher
  class MessagesController < ApplicationController
    def create
      chat_session = ChatSession.find_by_channel(params[:channel])
      if chat_session && chat_session.participating_user?(current_user)
        Pusher.trigger(params[:channel], 'message', params[:message],
                       params[:socket_id])
        head :created
      else
        render json: 'Forbidden', status: :forbidden
      end
    end
  end
end
