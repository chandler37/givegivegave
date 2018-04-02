json.extract! charity, :id, :name, :ein, :description, :score_overall, :score_financial, :score_accountability, :stars_overall, :stars_financial, :stars_accountability, :created_at, :updated_at
json.url charity_url(charity, format: :json)
