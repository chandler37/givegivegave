require 'rails_helper'

RSpec.describe "Charities", type: :request do
  # TODO(chandler37): include Devise::Test::ControllerHelpers maybe?
  describe "GET /charities" do
    it "redirects for unauthenticated folks" do
      get charities_path
      expect(response).to have_http_status(302)
    end
    it "works for authenticated users" do
      # TODO(chandler37): mock whatever needs mocking inside of cancancan and devise
      get charities_path
      expect(response).to have_http_status(200)
    end
  end
end
