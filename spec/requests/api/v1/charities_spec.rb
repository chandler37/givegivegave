# https://relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec
RSpec.describe "Charities", type: :request do
  let!(:user) { create :user }
  let!(:admin) { create :admin }
  let(:charity) { create :charity }
  let(:content_type_json) { { "CONTENT_TYPE" => "application/json" } }
  let(:accept_json) { { "ACCEPT" => "application/json" } }

  before do
    allow(Time).to receive(:now).and_return Time.at(37)
    allow(DateTime).to receive(:now).and_return DateTime.parse(Time.at(37).to_s)
  end

  describe "index: GET /api/v1/charities" do
    it "redirects for unauthenticated folks" do
      get api_charities_path
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(new_user_session_path)
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

      context "format json" do
        specify "not a search" do
          charity
          sign_in user
          get api_charities_path, headers: accept_json
          expect(response).to have_http_status(200)
          expect(JSON.parse(response.body)).to eq([{"id"=>charity.id,
                                                    "name"=>charity.name,
                                                    "ein"=>charity.ein,
                                                    "description"=>nil,
                                                    "score_overall"=>nil,
                                                    "stars_overall"=>nil,
                                                    "created_at"=>"1970-01-01T00:00:37.000Z",
                                                    "causes" => [],
                                                    "url"=>"http://www.example.com/api/v1/charities/#{charity.id}.json"}])
        end
        specify "a search" do
          orange = create :charity, name: "orange"
          create :charity, name: "banana"
          sign_in user
          get(
            api_charities_path,
            params: {search: orange.name},
            headers: accept_json
          )
          expect(response).to have_http_status(200)
          expect(JSON.parse(response.body)).to eq([{"id"=>orange.id,
                                                    "name"=>orange.name,
                                                    "ein"=>orange.ein,
                                                    "description"=>nil,
                                                    "score_overall"=>nil,
                                                    "stars_overall"=>nil,
                                                    "created_at"=>"1970-01-01T00:00:37.000Z",
                                                    "causes" => [],
                                                    "url"=>"http://www.example.com/api/v1/charities/#{orange.id}.json"}])
        end
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

  describe "show: GET /api/v1/charities/:id" do
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
        cause0 = create(:cause, name: "Health")
        cause0_child = create(:cause, parent_id: cause0.id, name: "Diseases")
        cause2 = create(:cause, name: "Education")
        charity.causes << cause0_child
        charity.causes << cause2
        expect(cause0_child.parent_id).to eq cause0.id
        expect(cause0_child.parent).to eq cause0
        expect(cause0.children).to eq [cause0_child]
        expect(charity.causes.size).to eq 2
        expect(charity.causes.map { |cause| cause.id }).to eq [cause0_child.id, cause2.id]
        get api_charity_path(charity), headers: accept_json
        expect(response).to have_http_status(200)
        gold = {
          "id"=>charity.id,
          "name"=>charity.name,
          "ein"=>charity.ein,
          "description"=>nil,
          "score_overall"=>nil,
          "stars_overall"=>nil,
          "created_at"=>"1970-01-01T00:00:37.000Z",
          "causes" => [{"id"=>cause0_child.id, "full_name"=>"Health/Diseases"},
                       {"id"=>cause2.id, "full_name"=>cause2.full_name}],
          "url"=>"http://www.example.com/api/v1/charities/#{charity.id}.json"}
        expect(JSON.parse(response.body)).to eq(gold)
      end
    end

    it "works for authenticated admins" do
      sign_in admin
      get api_charity_path(charity)
      expect(response).to have_http_status(200)
      expect(response.body).to include "Edit</a>"
    end
  end

  describe "update: PATCH /api/v1/charities/:id" do
    let!(:charity) { create :charity }

    it "redirects for unauthenticated folks" do
      patch api_charity_path(charity)
      expect(response).to have_http_status(302)
      expect(response.body).to include("example.com" + new_user_session_path + '"')
    end

    specify "redirects for authenticated non-admin users" do
      sign_in user
      patch api_charity_path(charity), params: {charity: {name: "New Name"}}.to_json, headers: content_type_json
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq "You are not authorized to access this page."
    end

    context "works for admins" do
      before { sign_in admin }

      specify "format html" do
        patch api_charity_path(charity), params: {charity: {name: "New Name"}}.to_json, headers: content_type_json
        expect(charity.reload.name).to eq "New Name"
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(api_charity_path(charity))
        expect(flash[:notice]).to eq "Charity was successfully updated."
      end

      specify "format json" do
        patch(
          api_charity_path(charity),
          params: {charity: {name: "New Name"}}.to_json,
          headers: content_type_json.merge(accept_json)
        )
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to eq({"id"=>charity.id,
                                                 "name"=>"New Name",
                                                 "ein"=>charity.ein,
                                                 "description"=>nil,
                                                 "score_overall"=>nil,
                                                 "stars_overall"=>nil,
                                                 "created_at"=>"1970-01-01T00:00:37.000Z",
                                                 "causes" => [],
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
      post api_charities_path, params: {charity: {name: "foobar"}}.to_json, headers: content_type_json
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq "You are not authorized to access this page."
    end

    context "works for admins" do
      before { sign_in admin }

      specify "unless the EIN already exists" do
        create :charity, ein: "0123"
        expect {
          post api_charities_path, params: {charity: {name: "foo", ein: "0123"}}.to_json, headers: content_type_json
        }.to change(Charity, :count).by(0)
        expect(response.body).to eq "{\"ein\":[\"has already been taken\"]}"
        expect(response).to have_http_status(422)
      end

      specify "and unless the name is empty" do
        expect {
          post api_charities_path, params: {charity: {name: ""}}.to_json, headers: content_type_json
        }.to change(Charity, :count).by(0)
        expect(response.body).to eq "{\"name\":[\"can't be blank\"]}"
        expect(response).to have_http_status(422)
      end

      specify "format html" do
        post api_charities_path, params: {charity: {name: "foobar"}}.to_json, headers: content_type_json
        expect(Charity.last.name).to eq "foobar"
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(api_charity_url(Charity.last))
      end

      specify "format json" do
        post(
          api_charities_path,
          params: {charity: {name: "a charity"}}.to_json,
          headers: content_type_json.merge(accept_json)
        )
        expect(response).to have_http_status(201)
        charity = Charity.last
        expect(JSON.parse(response.body)).to eq({"id"=>charity.id,
                                                 "name"=>"a charity",
                                                 "ein"=>nil,
                                                 "description"=>nil,
                                                 "score_overall"=>nil,
                                                 "stars_overall"=>nil,
                                                 "created_at"=>"1970-01-01T00:00:37.000Z",
                                                 "causes" => [],
                                                 "url"=>"http://www.example.com/api/v1/charities/#{charity.id}.json"})
      end
    end
  end

end
