json.array!(@profile_comments) do |profile_comment|
  json.extract! profile_comment, :id, :commenter_id, :receiver_id, :comment_text
  json.url profile_comment_url(profile_comment, format: :json)
end
