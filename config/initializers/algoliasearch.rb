application_id = ENV["ALGOLIA_APPLICATION_ID"]
if application_id.present?
  api_key = ENV["ALGOLIA_API_KEY"]
  unless api_key.present?
    raise "ALGOLIA_API_KEY is required if ALGOLIA_APPLICATION_ID is given"
  end
  AlgoliaSearch.configuration = {
    application_id: application_id,
    api_key: api_key,
    connect_timeout: 2,
    receive_timeout: 30,
    send_timeout: 30,
    batch_timeout: 120,
    search_timeout: 5
  }
  Rails.logger.info "Algolia initialized"
end
