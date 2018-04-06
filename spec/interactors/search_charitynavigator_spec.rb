# coding: utf-8
RSpec.describe SearchCharitynavigator, type: :interactor do
  let(:real_acs_ein) { "131788491" }
  let(:real_acs_json_via_ein_search) {
    {
      "activeAdvisories" => {"_rapid_links"=>{"related"=>{"href"=>"https://api.data.charitynavigator.org/v2/Organizations/131788491/Advisories?status=ACTIVE"}}},
      "category" => {"image"=>"https://d20umu42aunjpx.cloudfront.net/_gfx_/icons/categories/environment.png?utm_source=DataAPI&utm_content=02c960ca", "charityNavigatorURL"=>"https://www.charitynavigator.org/index.cfm?bay=search.categories&categoryid=5&utm_source=DataAPI&utm_content=02c960ca", "categoryName"=>"Health", "categoryID"=>5},
      "cause" => {"causeID"=>13, "charityNavigatorURL"=>"https://www.charitynavigator.org/index.cfm?bay=search.results&cgid=5&cuid=13&utm_source=DataAPI&utm_content=02c960ca", "causeName"=>"Diseases, Disorders, and Disciplines", "image"=>"https://d20umu42aunjpx.cloudfront.net/_gfx_/causes/small/diseases.gif?utm_source=DataAPI&utm_content=02c960ca"},
      "charityName" => "American Cancer Society",
      "charityNavigatorURL" => "https://www.charitynavigator.org/?bay=search.summary&orgid=6495&utm_source=DataAPI&utm_content=02c960ca",
      "currentRating" => {"score"=>71.48, "ratingID"=>121921, "publicationDate"=>"2017-11-01T04:00:00.000Z", "ratingImage"=>{"small"=>"https://d20umu42aunjpx.cloudfront.net/_gfx_/icons/stars/2starsb.png", "large"=>"https://d20umu42aunjpx.cloudfront.net/_gfx_/icons/stars/2stars.png"}, "rating"=>2, "_rapid_links"=>{"related"=>{"href"=>"https://api.data.charitynavigator.org/v2/Organizations/131788491/Ratings/121921"}}},
      "donationAddress" => {"country"=>nil, "stateOrProvince"=>"OK", "city"=>"Oklahoma City", "postalCode"=>"73123", "streetAddress1"=>"P.O. Box 22478", "streetAddress2"=>nil},
      "ein" => "131788491",
      "irsClassification" => {"deductibility"=>"Contributions are deductible", "subsection"=>"501(c)(3)", "nteeType"=>"Diseases, Disorders, Medical Disciplines", "foundationStatus"=>"Organization which receives a substantial part of its support from a governmental unit or the general public   170(b)(1)(A)(vi)", "nteeSuffix"=>"0", "nteeClassification"=>"Cancer", "deductibilityDetail"=>nil, "nteeCode"=>"G30", "nteeLetter"=>"G"},
      "mailingAddress" => {"country"=>nil, "stateOrProvince"=>"GA", "city"=>"Atlanta", "postalCode"=>"30303", "streetAddress1"=>"250 Williams Street, NW", "streetAddress2"=>nil},
      "mission" => "The American Cancer Society's mission is to save lives, celebrate lives, and lead the fight for a world without cancer.",
      "removedAdvisories" => {"_rapid_links"=>{"related"=>{"href"=>"https://api.data.charitynavigator.org/v2/Organizations/131788491/Advisories?status=REMOVED"}}},
      "tagLine" => "Save lives, celebrate lives, and lead the fight for a world without cancer.",
       "websiteURL" => "http://www.cancer.org",
    }
  }
  let(:real_acs_json_via_keyword_search) {
    {
      "advisories" => {"severity"=>nil, "active"=>{"_rapid_links"=>{"related"=>{"href"=>"https://api.data.charitynavigator.org/v2/Organizations/131788491/Advisories?status=ACTIVE"}}}},
      "category" => {"categoryName"=>"Health", "categoryID"=>5, "charityNavigatorURL"=>"https://www.charitynavigator.org/index.cfm?bay=search.categories&categoryid=5&utm_source=DataAPI&utm_content=02c960ca", "image"=>"https://d20umu42aunjpx.cloudfront.net/_gfx_/icons/categories/environment.png?utm_source=DataAPI&utm_content=02c960ca"},
      "cause" => {"causeID"=>13, "causeName"=>"Diseases, Disorders, and Disciplines", "charityNavigatorURL"=>"https://www.charitynavigator.org/index.cfm?bay=search.results&cgid=5&cuid=13&utm_source=DataAPI&utm_content=02c960ca", "image"=>"https://d20umu42aunjpx.cloudfront.net/_gfx_/causes/small/diseases.gif?utm_source=DataAPI&utm_content=02c960ca"},
      "charityName" => "American Cancer Society",
      "charityNavigatorURL" => "https://www.charitynavigator.org/?bay=search.summary&orgid=6495&utm_source=DataAPI&utm_content=02c960ca",
      "currentRating" => {"ratingImage"=>{"small"=>"https://d20umu42aunjpx.cloudfront.net/_gfx_/icons/stars/2starsb.png", "large"=>"https://d20umu42aunjpx.cloudfront.net/_gfx_/icons/stars/2stars.png"}, "rating"=>2},
      "donationAddress" => {"country"=>nil, "stateOrProvince"=>"OK", "city"=>"Oklahoma City", "postalCode"=>"73123", "streetAddress1"=>"P.O. Box 22478", "streetAddress2"=>nil},
      "ein" => "131788491",
      "irsClassification" => {"deductibility"=>"Contributions are deductible", "subsection"=>"501(c)(3)", "nteeType"=>"Diseases, Disorders, Medical Disciplines", "foundationStatus"=>"Organization which receives a substantial part of its support from a governmental unit or the general public   170(b)(1)(A)(vi)", "nteeSuffix"=>"0", "nteeClassification"=>"Cancer", "deductibilityDetail"=>nil, "nteeCode"=>"G30", "nteeLetter"=>"G"},
      "mailingAddress" => {"country"=>nil, "stateOrProvince"=>"GA", "city"=>"Atlanta", "postalCode"=>"30303", "streetAddress1"=>"250 Williams Street, NW", "streetAddress2"=>nil},
      "mission" => "The American Cancer Society's mission is to save lives, celebrate lives, and lead the fight for a world without cancer.",
      "organization" => {"charityName"=>"American Cancer Society", "ein"=>"131788491", "charityNavigatorURL"=>"https://www.charitynavigator.org/?bay=search.summary&orgid=6495&utm_source=DataAPI&utm_content=02c960ca", "_rapid_links"=>{"related"=>{"href"=>"https://api.data.charitynavigator.org/v2/Organizations/131788491"}}},
      "tagLine" => "Save lives, celebrate lives, and lead the fight for a world without cancer.",
      "websiteURL" => "http://www.cancer.org",
    }
  }

  before do
    # To rerecord cassettes or add new cassettes you'll need a real API
    # key. Set the environment variables below using, e.g., `export
    # CHARITYNAVIGATOR_APP_ID=foo` in the same terminal you are using to run
    # rspec.
    ENV["CHARITYNAVIGATOR_APP_ID"] ||= "test"
    ENV["CHARITYNAVIGATOR_APP_KEY"] ||= "test"
  end

  describe "#call" do
    it "works for EIN tax ID searches" do
      VCR.use_cassette("charity_navigator/organizations/search_acs_ein") do
        result = described_class.call(ein: real_acs_ein)
        expect(result).to be_success
        expect(result.response_json).to be_a Array
        expect(result.response_json.size).to eq 1
        expect(result.response_json.first).to eq real_acs_json_via_ein_search
      end
    end
    it "works for keyword searches" do
      VCR.use_cassette("charity_navigator/organizations/search_acs") do
        result = described_class.call(search: "American Cancer Society")
        expect(result).to be_success
        expect(result.response_json).to be_a Array
        expect(result.response_json.size).to eq 100
        one = {
          "advisories" => {"severity"=>nil, "active"=>{"_rapid_links"=>{"related"=>{"href"=>"https://api.data.charitynavigator.org/v2/Organizations/522340031/Advisories?status=ACTIVE"}}}},
          "charityName" => "American Cancer Society Cancer Action Network Inc",
          "charityNavigatorURL" => "https://www.charitynavigator.org/?bay=search.profile&ein=522340031&utm_source=DataAPI&utm_content=02c960ca",
          "currentRating" => {"ratingImage"=>{"small"=>"https://d20umu42aunjpx.cloudfront.net/_gfx_/icons/stars/2starsb.png", "large"=>"https://d20umu42aunjpx.cloudfront.net/_gfx_/icons/stars/2stars.png"}, "rating"=>2},
          "ein" => "522340031",
          "irsClassification" => {"deductibility"=>"Contributions are not deductible", "subsection"=>"501(c)(4)", "nteeType"=>"Medical Research", "foundationStatus"=>"All organizations except 501(c)(3)", "nteeSuffix"=>nil, "nteeClassification"=>"Alliance/Advocacy Organizations ", "deductibilityDetail"=>nil, "nteeCode"=>"H01", "nteeLetter"=>"H"},
          "mailingAddress" => {"country"=>nil, "stateOrProvince"=>"DC", "city"=>"WASHINGTON", "postalCode"=>"20004-1311", "streetAddress1"=>"555 11TH ST NW STE 300", "streetAddress2"=>nil},
          "mission" => nil,
          "organization" => {"charityName"=>"American Cancer Society Cancer Action Network Inc", "ein"=>"522340031", "charityNavigatorURL"=>"https://www.charitynavigator.org/?bay=search.profile&ein=522340031&utm_source=DataAPI&utm_content=02c960ca", "_rapid_links"=>{"related"=>{"href"=>"https://api.data.charitynavigator.org/v2/Organizations/522340031"}}},
          "tagLine" => nil,
          "websiteURL" => nil
        }
        expect(result.response_json.first).to eq(one)
        real_one = result.response_json.find { |h| h["ein"] == real_acs_ein }
        expect(real_one).to eq real_acs_json_via_keyword_search
      end
    end
  end
end
