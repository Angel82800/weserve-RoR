json.extract! group_message, :id, :message, :user_id, :chatroom_id, :created_at, :updated_at
json.url group_message_url(group_message, format: :json)