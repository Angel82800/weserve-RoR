json.array!(@cards) do |card|
  json.extract! card, :id, :title, :status, :list
  json.url card_url(card, format: :json)
end
