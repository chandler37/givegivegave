FactoryBot.define do
  factory :cacheline do
    # the name is somewhat confusing because auth gets stripped:
    url_minus_auth "https://api.data.charitynavigator.org/v2/Organizations?app_id=CHARITYNAVIGATORAPPID&app_key=CHARITYNAVIGATORAPPKEY"

    body "HTTP can return all sorts of things that are not valid JSON"

    http_status 200
  end
end
