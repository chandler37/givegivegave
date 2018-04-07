# https://relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec
RSpec.describe "Charities", type: :request do
  let!(:user) { create :user }
  let!(:admin) { create :admin }
  let(:charity) { create :charity }
  let(:json_request_headers) { { "CONTENT_TYPE" => "application/json" } }

  before do
    allow(Time).to receive(:now).and_return Time.at(37)
    allow(DateTime).to receive(:now).and_return DateTime.parse(Time.at(37).to_s)
  end

  describe "index: GET /api/v1/charities" do
    it "redirects for unauthenticated folks" do
      get api_charities_path
      expect(response).to have_http_status(302)
    end

    context "works for authenticated non-admin users" do
      specify "format html" do
        sign_in user
        get api_charities_path
        expect(response).to have_http_status(200)
        expect(response.body).to include "Score overall"
        expect(response.body).not_to include "New Charity"
        expect(response.body).not_to include "Edit Charity"
      end

      specify "format json" do
        charity
        sign_in user
        get api_charities_path, headers: { "ACCEPT" => "application/json" }
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to eq([{"id"=>charity.id,
                                                  "name"=>charity.name,
                                                  "ein"=>charity.ein,
                                                  "description"=>nil,
                                                  "score_overall"=>nil,
                                                  "stars_overall"=>nil,
                                                  "created_at"=>"1970-01-01T00:00:37.000Z",
                                                  "updated_at"=>"1970-01-01T00:00:37.000Z",
                                                  "url"=>"http://www.example.com/api/v1/charities/#{charity.id}.json"}])
      end
    end

    it "works for authenticated admins" do
      charity
      sign_in admin
      get api_charities_path
      expect(response).to have_http_status(200)
      expect(response.body).to include "New Charity</a>"
      expect(response.body).to include "Edit</a>"
    end
  end

  describe "show: GET /api/v1/charities/{id}" do
    it "redirects for unauthenticated folks" do
      get api_charity_path(charity)
      expect(response).to have_http_status(302)
      expect(response.body).to include("example.com" + new_user_session_path + '"')
    end

    context "works for authenticated non-admin users" do
      specify "format html" do
        sign_in user
        get api_charity_path(charity)
        expect(response).to have_http_status(200)
        expect(response.body).to include "Score overall"
        expect(response.body).not_to include "Edit"
      end

      specify "format json" do
        sign_in user
        get api_charity_path(charity), headers: { "ACCEPT" => "application/json" }
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to eq({"id"=>charity.id,
                                                 "name"=>charity.name,
                                                 "ein"=>charity.ein,
                                                 "description"=>nil,
                                                 "score_overall"=>nil,
                                                 "stars_overall"=>nil,
                                                 "created_at"=>"1970-01-01T00:00:37.000Z",
                                                 "updated_at"=>"1970-01-01T00:00:37.000Z",
                                                 "url"=>"http://www.example.com/api/v1/charities/#{charity.id}.json"})
      end
    end

    it "works for authenticated admins" do
      sign_in admin
      get api_charity_path(charity)
      expect(response).to have_http_status(200)
      expect(response.body).to include "Edit</a>"
    end
  end

  describe "update: PATCH /api/v1/charities/{id}" do
    let!(:charity) { create :charity }

    it "redirects for unauthenticated folks" do
      patch api_charity_path(charity)
      expect(response).to have_http_status(302)
      expect(response.body).to include("example.com" + new_user_session_path + '"')
    end

    specify "redirects for authenticated non-admin users" do
      sign_in user
      patch api_charity_path(charity), params: {charity: {name: "New Name"}}.to_json, headers: json_request_headers
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq "You are not authorized to access this page."
    end

    context "works for admins" do
      before { sign_in admin }

      specify "format html" do
        patch api_charity_path(charity), params: {charity: {name: "New Name"}}.to_json, headers: json_request_headers
        expect(charity.reload.name).to eq "New Name"
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(api_charity_path(charity))
        expect(flash[:notice]).to eq "Charity was successfully updated."
      end

      specify "format json" do
        patch api_charity_path(charity), params: {charity: {name: "New Name"}}.to_json, headers: json_request_headers.merge({ "ACCEPT" => "application/json" })
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to eq({"id"=>charity.id,
                                                 "name"=>"New Name",
                                                 "ein"=>charity.ein,
                                                 "description"=>nil,
                                                 "score_overall"=>nil,
                                                 "stars_overall"=>nil,
                                                 "created_at"=>"1970-01-01T00:00:37.000Z",
                                                 "updated_at"=>"1970-01-01T00:00:37.000Z",
                                                 "url"=>"http://www.example.com/api/v1/charities/#{charity.id}.json"})
      end
    end
  end

  describe "create: POST /api/v1/charities" do
    it "redirects for unauthenticated folks" do
      post api_charities_path
      expect(response).to have_http_status(302)
      expect(response.body).to include("example.com" + new_user_session_path + '"')
    end

    specify "redirects for authenticated non-admin users" do
      sign_in user
      post api_charities_path, params: {charity: {name: "foobar"}}.to_json, headers: json_request_headers
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq "You are not authorized to access this page."
    end

    context "works for admins" do
      before { sign_in admin }

      specify "unless the EIN already exists" do
        create :charity, ein: "0123"
        expect {
          post api_charities_path, params: {charity: {name: "foo", ein: "0123"}}.to_json, headers: json_request_headers
        }.to change(Charity, :count).by(0)
        expect(response.body).to eq "{\"ein\":[\"has already been taken\"]}"
        expect(response).to have_http_status(422)
      end

      specify "and unless the name is empty" do
        expect {
          post api_charities_path, params: {charity: {name: ""}}.to_json, headers: json_request_headers
        }.to change(Charity, :count).by(0)
        expect(response.body).to eq "{\"name\":[\"can't be blank\"]}"
        expect(response).to have_http_status(422)
      end

      specify "format html" do
        post api_charities_path, params: {charity: {name: "foobar"}}.to_json, headers: json_request_headers
        expect(Charity.last.name).to eq "foobar"
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(api_charity_url(Charity.last))
      end

      specify "format json" do
        post api_charities_path, params: {charity: {name: "a charity"}}.to_json, headers: json_request_headers.merge({ "ACCEPT" => "application/json" })
        expect(response).to have_http_status(201)
        charity = Charity.last
        expect(JSON.parse(response.body)).to eq({"id"=>charity.id,
                                                 "name"=>"a charity",
                                                 "ein"=>nil,
                                                 "description"=>nil,
                                                 "score_overall"=>nil,
                                                 "stars_overall"=>nil,
                                                 "created_at"=>"1970-01-01T00:00:37.000Z",
                                                 "updated_at"=>"1970-01-01T00:00:37.000Z",
                                                 "url"=>"http://www.example.com/api/v1/charities/#{charity.id}.json"})
      end
    end
  end

end
