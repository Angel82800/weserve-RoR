json.array!(@projects) do |project|
  json.extract! project, :id, :title, :description, :country, :picture
  json.url project_url(project, format: :json)
end
