json.extract! charity, :id, :name, :ein, :description, :score_overall, :stars_overall, :created_at
json.causes charity.causes, :id, :full_name
json.url api_charity_url(charity, format: :json)
