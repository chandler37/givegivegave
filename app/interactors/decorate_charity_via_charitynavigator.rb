class DecorateCharityViaCharitynavigator
  include Interactor

  delegate :ein, to: :context

  def call
    canonincal_ein = Charity.canonical_ein(ein)

    charity = Charity.find_by(ein: canonincal_ein)

    if charity.nil?
      charity = Charity.create!(ein: canonincal_ein, name: "? ?? ??? ?????")
    end

    result = SearchCharitynavigator.call(ein: canonincal_ein)

    unless result.success?
      context.fail!(error: result.error)
    end

    unless result.response_json.size == 1
      context.fail!(error: "expected a single API response")
    end

    json = result.response_json.first

    charity.update_attributes!(
      name: json["charityName"],
      stars_overall: json["currentRating"].try(:[], "rating"),
      score_overall: json["currentRating"].try(:[], "score"),
      description: json["mission"],
      website: json["websiteURL"]
    )

    # TODO(chandler37): add more. we have Cacheline so that we don't need to
    # hit their API to change our business logic.

    context.charity = charity
  end
end
