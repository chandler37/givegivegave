class Charity < ApplicationRecord
  validates :name, presence: true
  validates :ein, uniqueness: true

  # TODO(chandler37): store the original EIN with "-" in it for display?

  before_validation :normalize_ein

  private

  def normalize_ein
    if ein.present?
      self.ein = ein.strip.downcase.gsub("-", "")
    end
  end
end
