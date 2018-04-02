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
    specify "works to GET /v2/Organizations" do
      VCR.use_cassette("charity_navigator/organizations/default") do
        body = described_class.get("/Organizations")
        expect(body).to be_a Array
        expect(body.first).to be_a Hash
        expect(body.first.keys.sort).to eq(["advisories", "charityName", "charityNavigatorURL", "ein", "irsClassification", "mailingAddress", "mission", "organization", "tagLine", "websiteURL"])
        expect(body.first["charityNavigatorURL"]).to match(/https:\/\/www.charitynavigator.org\/.bay=search.profile&ein=/)
      end
    end
  end
end
