class Charity < ApplicationRecord
  validates :name, presence: true
  validates :ein, uniqueness: true

  before_validation :normalize_ein

  def self.some_golden_data_by_ein # useful for seeding and testing
    # TODO(chandler37): Integrate with other data sources to obtain correct
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
      "53-0196605" => {name: "American Red Cross",
                       website: "http://www.redcross.org"},
      "13-1635294" => {name: "United Way Worldwide",
                       website: "http://www.unitedway.org/"},
      "13-3039601" => {name: "alzheimer's association",
                       website: "http://www.alz.org"},
      "57-0881347" => {name: "South Carolina Governor's School for Science and Math Foundation",
                       website: "https://www.scgssm.org/support/gssm-foundation-board"}
    }
  end

  def self.canonical_ein(ein)
    # TODO(chandler37): How shall we deal with 8-digit EINs: leading zero?
    ein.strip.downcase.gsub("-", "")
  end

  private

  def normalize_ein
    if ein.present?
      self.ein = self.class.canonical_ein(ein)
    end
  end
end
