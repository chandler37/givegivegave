class Charity < ApplicationRecord
  if ENV["ALGOLIA_APPLICATION_ID"].present?
    include AlgoliaSearch

    # index name is Charity_development or Charity_production:
    algoliasearch(
      per_environment: true,
      sanitize: true,
      force_utf8_encoding: true,
      disable_indexing: Rails.env.test?
    ) do
      attribute :name, :ein, :display_ein, :description, :website, :score_overall, :stars_overall

      # By order of importance. `description` is tagged as `unordered` to avoid
      # taking the position of a match into account in that attribute.
      searchableAttributes ['ein', 'display_ein', 'name', 'website', 'unordered(description)']

      # the ranking criteria use to compare two matching records in case their
      # text-relevance is equal:
      customRanking ['desc(score_overall)']
    end
  end

  validates :name, presence: true
  validates :ein, uniqueness: true, if: Proc.new { |c| c.ein.present? }

  before_validation :normalize_ein

  def display_ein
    return nil if ein.blank?
    return ein unless ein =~ /\A\d{8,9}\z/
    if ein.size == 8
      "0#{ein[0]}-#{ein[1..-1]}"
    else
      "#{ein[0..1]}-#{ein[2..-1]}"
    end
  end

  def display_ein_changed?  # so algolia doesn't reindex needlessly
    ein_changed?
  end

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
