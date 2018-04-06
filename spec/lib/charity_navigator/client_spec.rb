RSpec.describe CharityNavigator::Client do
  before do
    # To rerecord cassettes or add new cassettes you'll need a real API
    # key. Set the environment variables below using, e.g., `export
    # CHARITYNAVIGATOR_APP_ID=foo` in the same terminal you are using to run
    # rspec.
    ENV["CHARITYNAVIGATOR_APP_ID"] ||= "test"
    ENV["CHARITYNAVIGATOR_APP_KEY"] ||= "test"
  end
  describe "#get" do
    specify "works to GET /v2/Organizations and caches" do
      body = nil
      VCR.use_cassette("charity_navigator/organizations/default") do
        body = described_class.get("/Organizations")
        expect(body).to be_a Array
        expect(body.first).to be_a Hash
        expect(body.first.keys.sort).to eq(["advisories", "charityName", "charityNavigatorURL", "ein", "irsClassification", "mailingAddress", "mission", "organization", "tagLine", "websiteURL"])
        expect(body.first["charityNavigatorURL"]).to match(/https:\/\/www.charitynavigator.org\/.bay=search.profile&ein=/)
      end
      expect(Cacheline.first.url_minus_auth).to eq "https://api.data.charitynavigator.org/v2/Organizations?"
      # We have no cassette here so you know it's not hitting the API:
      expect(described_class.get("/Organizations")).to eq body
    end
  end
end
