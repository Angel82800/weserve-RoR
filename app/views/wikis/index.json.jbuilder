json.array!(@wikis) do |wiki|
  json.extract! wiki, :id, :title, :description, :pictureone, :string, :picturetwo, :picturethree, :picturefour, :picturefive
  json.url wiki_url(wiki, format: :json)
end
