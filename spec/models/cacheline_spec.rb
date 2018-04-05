require 'rails_helper'

RSpec.describe Cacheline, type: :model do
  context "validates input" do
    specify "validates URL" do
      expect {
        create :cacheline, url_minus_auth: "foo"
      }.to raise_error ActiveRecord::RecordInvalid, /Validation failed: Url minus auth is invalid/
    end
    specify "validates HTTP status" do
      expect {
        create :cacheline, http_status: 204
      }.to raise_error ActiveRecord::RecordInvalid, /Validation failed: Http status must be equal to 200/
    end
  end
  context "strips authentication" do
    let(:url_with_auth0) { "https://api.data.charitynavigator.org/v2/Organizations?app_id=CHARITYNAVIGATORAPPID&app_key=CHARITYNAVIGATORAPPKEY" }
    let(:url_without_auth0) { "https://api.data.charitynavigator.org/v2/Organizations?app_id=<APP_ID>&app_key=<APP_KEY>" }
    specify "for charitynavigator" do
      cl0 = create :cacheline, url_minus_auth: url_with_auth0
      expect(cl0.url_minus_auth).to eq url_without_auth0
      cl1 = build :cacheline, url_minus_auth: url_with_auth0
      expect(cl1.url_minus_auth).to eq url_with_auth0
      expect {
        cl1.save!
      }.to raise_error ActiveRecord::RecordNotUnique
      cl0.destroy
      cl1.save!
      expect(cl1.reload.url_minus_auth).to eq url_without_auth0
    end
  end
#  context "compresses bodies" do
#  end
end
