json.array!(@plans) do |plan|
  json.extract! plan, :id, :notes, :todos, :owner, :status, :body
  json.url plan_url(plan, format: :json)
end
