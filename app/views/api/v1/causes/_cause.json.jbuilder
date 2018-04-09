json.extract! cause, :id, :parent_id, :name, :full_name, :description, :created_at
json.children cause.children, :id, :name
json.url api_cause_url(cause, format: :json)
