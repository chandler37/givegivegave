class Cause < ApplicationRecord
  if ENV["ALGOLIA_APPLICATION_ID"].present?
    include AlgoliaSearch

    # index name is Cause_development or Cause_production:
    algoliasearch(
      per_environment: true,
      sanitize: true,
      force_utf8_encoding: true,
      disable_indexing: Rails.env.test?
    ) do
      attribute :name, :full_name, :description

      # By order of importance. `description` is tagged as `unordered` to avoid
      # taking the position of a match into account in that attribute.
      searchableAttributes ['full_name', 'name', 'unordered(description)']
    end
  end

  belongs_to :parent, class_name: 'Cause', optional: true
  has_many :children, class_name: 'Cause', foreign_key: 'parent_id'
  has_and_belongs_to_many :charities

  validates :name, presence: true

  def full_name
    return nil if name.blank?
    return name if parent_id.nil?
    "#{parent.full_name}/#{name}"
  end

  def full_name_changed?  # so algolia doesn't reindex needlessly
    parent_id_changed? || name_changed?
  end

  # Does not alter the join table!
  def recursively_destroy!
    children.each { |c| c.recursively_destroy! }
    destroy
  end

  # This has worse search quality (information retrieval quality) than using
  # Algolia (which knows about parent causes) but will not grind the database
  # to a halt because this is such a tiny table. Consider Algolia's #search or
  # #raw_search methods.
  def self.table_scan_search(query)
    # postgres extension: ILIKE: case-insensitive LIKE
    where(
      "name ILIKE :q OR description ILIKE :q",
      q: query
    )
  end
end
