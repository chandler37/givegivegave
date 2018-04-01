# spec/support/vcr_setup.rb
require "vcr"
VCR.configure do |c|
  #the directory where your cassettes will be saved
  c.cassette_library_dir = "spec/cassettes"
  # your HTTP request service. You can also use fakeweb, webmock, and more
  c.hook_into :faraday
  c.default_cassette_options  = {
    record: :once,
    match_requests_on: [:method, :body, :uri],
    allow_unused_http_interactions: false
  }
  c.filter_sensitive_data("<CHARITYNAVIGATOR_APP_ID>") { ENV["CHARITYNAVIGATOR_APP_ID"] || "" }
  c.filter_sensitive_data("<CHARITYNAVIGATOR_APP_KEY>") { ENV["CHARITYNAVIGATOR_APP_KEY"] || "" }
end
