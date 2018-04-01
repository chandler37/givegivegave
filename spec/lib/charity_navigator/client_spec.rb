# TODO(chandler37): Use VCR to record the http call
RSpec.describe CharityNavigator::Client do
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
