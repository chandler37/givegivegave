RSpec.describe DecorateCharityViaCharitynavigator, type: :interactor do
  let(:golden_charity_data_by_ein) {
    # TODO(chandler37): Integrrate with other data sources to obtain correct
    # websites where website is nil:
    {
      # metacharities:
      "52-1070270" => {name: "bbb wise giving alliance",
                       website: nil, correct_website: "give.org"},
      "68-0480736" => {name: "network for good inc.",
                       website: nil, correct_website: "networkforgood.com"},
      "13-1837418" => {name: "foundation center",
                       website: nil, correct_website: "foundationcenter.org"},
      "33-0491030" => {name: "AMERICAN INSTITUTE OF PHILANTHROPY",
                       website: nil, correct_website: "charitywatch.org"},
      "54-1774039" => {name: "GUIDESTAR USA INC.",
                       website: nil, correct_website: "guidestar.org"},
      "14-2007220" => {name: "ProPublica",
                       website: "http://www.propublica.org/"},

      # charities:
      "13-1635294" => {name: "United Way Worldwide",
                       website: "http://www.unitedway.org/"},
      "13-3039601" => {name: "alzheimer's association",
                       website: "http://www.alz.org"},
      "57-0881347" => {name: "South Carolina Governor's School for Science and Math Foundation",
                       website: "https://www.scgssm.org/support/gssm-foundation-board"}
    }
  }

  describe "#call" do
    let!(:charity) { create :charity, ein: "680384748", name: "foobarbazquux" }

    specify "has websites" do
      golden_charity_data_by_ein.each do |ein, hsh|
        canonical_ein = Charity.canonical_ein(ein)
        result = VCR.use_cassette("charity_navigator/organizations/search_ein_#{canonical_ein}") do
          described_class.call(ein: canonical_ein)
        end
        expect(result).to be_success
        expect(result.charity.name.downcase).to eq hsh[:name].downcase
        expect(result.charity.website).to eq hsh[:website]
      end
    end

    specify "creates charities" do
      result = VCR.use_cassette("charity_navigator/organizations/search_acs_ein") do
        described_class.call(ein: "131788491")
      end
      expect(result).to be_success
      golden = { # TODO(chandler37): remove and rename fields
        "description" => "The American Cancer Society's mission is to save lives, celebrate lives, and lead the fight for a world without cancer.",
        "ein" => "131788491",
        "name" => "American Cancer Society",
        "score_accountability" => nil,
        "score_financial" => nil,
        "score_overall" => 71.48,
        "stars_accountability" => nil,
        "stars_financial" => nil,
        "stars_overall" => 2,
        "website" => "http://www.cancer.org",
      }

      expect(result.charity.reload.attributes.except("created_at", "updated_at", "id")).to eq(golden)
    end

    specify "decorates existing charities" do
      result = VCR.use_cassette("charity_navigator/organizations/search_long_now_ein") do
        described_class.call(ein: "68-0384748")
      end
      expect(result).to be_success
      expect(result.charity).to be_present
      golden = {
        "description" => "The Long Now Foundation was established in 01996* to develop the Clock and Library projects, as well as to become the seed of a very long-term cultural institution. The Long Now Foundation hopes to provide a counterpoint to today's accelerating culture and help make long-term thinking more common. We hope to foster responsibility in the framework of the next 10,000 years.",
        "ein" => "680384748",
        "name" => "Long Now Foundation",
        "score_accountability" => nil,
        "score_financial" => nil,
        "score_overall" => 86.51,
        "stars_accountability" => nil,
        "stars_financial" => nil,
        "stars_overall" => 3,
        "website" => "http://longnow.org/",
      }

      expect(result.charity.reload.attributes.except("created_at", "updated_at", "id")).to eq(golden)
    end

    specify "handles bad EINs gracefully" do
      result = VCR.use_cassette("charity_navigator/organizations/search_1234_ein") do
        described_class.call(ein: "12-34")
      end
      expect(result).to be_failure
      expect(result.error).to eq "EIN not found"
    end
  end
end
