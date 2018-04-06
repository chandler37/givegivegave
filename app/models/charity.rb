class Charity < ApplicationRecord
  validates :name, presence: true
  validates :ein, uniqueness: true

  # TODO(chandler37): store the original EIN with "-" in it for display?

  before_validation :normalize_ein

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
