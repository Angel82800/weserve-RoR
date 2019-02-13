json.array!(@work_records) do |work_record|
  json.extract! work_record, :id
  json.url work_record_url(work_record, format: :json)
end
