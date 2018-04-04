require 'rails_helper'

RSpec.describe "Charities", type: :request do
  let!(:user) { User.create!(email: "a@b.c", password: "very-secret") }

  describe "GET /charities" do
    it "redirects for unauthenticated folks" do
      get charities_path
      expect(response).to have_http_status(302)
    end
    it "works for authenticated users" do
      sign_in user
      get charities_path
      expect(response).to have_http_status(200)
    end
  end
end
