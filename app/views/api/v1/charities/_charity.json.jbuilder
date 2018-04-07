json.extract! charity, :id, :name, :ein, :description, :score_overall, :stars_overall, :created_at, :updated_at
json.url api_charity_url(charity, format: :json)
