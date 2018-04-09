# https://relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec
RSpec.describe "Causes", type: :request do
  let!(:user) { create :user }
  let!(:admin) { create :admin }
  let(:cause) { create :cause }
  let(:content_type_json) { { "CONTENT_TYPE" => "application/json" } }
  let(:accept_json) { { "ACCEPT" => "application/json" } }

  before do
    allow(Time).to receive(:now).and_return Time.at(37)
    allow(DateTime).to receive(:now).and_return DateTime.parse(Time.at(37).to_s)
  end

  describe "index: GET /api/v1/causes" do
    it "redirects for unauthenticated folks" do
      get api_causes_path
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(new_user_session_path)
    end

    context "works for authenticated non-admin users" do
      specify "format html" do
        sign_in user
        get api_causes_path
        expect(response).to have_http_status(200)
        expect(response.body).to include "Description"
        expect(response.body).not_to include "New Cause"
        expect(response.body).not_to include "Edit Cause"
      end

      context "format json" do
        specify "not a search" do
          cause
          sign_in user
          get api_causes_path, headers: accept_json
          expect(response).to have_http_status(200)
          expect(JSON.parse(response.body)).to eq([{"id"=>cause.id,
                                                    "parent_id"=>cause.parent_id,
                                                    "name"=>cause.name,
                                                    "full_name"=>cause.full_name,
                                                    "description"=>nil,
                                                    "created_at"=>"1970-01-01T00:00:37.000Z",
                                                    "children" => [],
                                                    "url"=>"http://www.example.com/api/v1/causes/#{cause.id}.json"}])
        end
        specify "a search" do
          orange = create :cause, name: "orange"
          create :cause, name: "banana"
          sign_in user
          get(
            api_causes_path,
            params: {search: orange.name},
            headers: accept_json
          )
          expect(response).to have_http_status(200)
          expect(JSON.parse(response.body)).to eq([{"id"=>orange.id,
                                                    "parent_id"=>orange.parent_id,
                                                    "name"=>orange.name,
                                                    "full_name"=>orange.full_name,
                                                    "description"=>nil,
                                                    "created_at"=>"1970-01-01T00:00:37.000Z",
                                                    "children" => [],
                                                    "url"=>"http://www.example.com/api/v1/causes/#{orange.id}.json"}])
        end
      end
    end

    it "works for authenticated admins" do
      cause
      sign_in admin
      get api_causes_path
      expect(response).to have_http_status(200)
      expect(response.body).to include "New Cause</a>"
      expect(response.body).to include "Edit</a>"
    end
  end

  describe "show: GET /api/v1/causes/:id" do
    it "redirects for unauthenticated folks" do
      get api_cause_path(cause)
      expect(response).to have_http_status(302)
      expect(response.body).to include("example.com" + new_user_session_path + '"')
    end

    context "works for authenticated non-admin users" do
      specify "format html" do
        cause.update_attributes!(parent_id: create(:cause).id)
        sign_in user
        get api_cause_path(cause)
        expect(response).to have_http_status(200)
        expect(response.body).to include "Description"
        expect(response.body).not_to include "Edit"
      end

      specify "format json" do
        child = create :cause, parent_id: cause.id
        sign_in user
        get api_cause_path(cause), headers: accept_json
        expect(response).to have_http_status(200)
        gold = {
          "id"=>cause.id,
          "parent_id"=>cause.parent_id,
          "name"=>cause.name,
          "full_name"=>cause.full_name,
          "description"=>nil,
          "created_at"=>"1970-01-01T00:00:37.000Z",
          "children" => [{"id"=>child.id, "name"=>child.name}],
          "url"=>"http://www.example.com/api/v1/causes/#{cause.id}.json"}
        expect(JSON.parse(response.body)).to eq(gold)
      end
    end

    it "works for authenticated admins" do
      sign_in admin
      get api_cause_path(cause)
      expect(response).to have_http_status(200)
      expect(response.body).to include "Edit</a>"
    end
  end

  describe "update: PATCH /api/v1/causes/:id" do
    let!(:cause) { create :cause }

    it "redirects for unauthenticated folks" do
      patch api_cause_path(cause)
      expect(response).to have_http_status(302)
      expect(response.body).to include("example.com" + new_user_session_path + '"')
    end

    specify "redirects for authenticated non-admin users" do
      sign_in user
      patch api_cause_path(cause), params: {cause: {name: "New Name"}}.to_json, headers: content_type_json
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq "You are not authorized to access this page."
    end

    context "works for admins" do
      before { sign_in admin }

      context "format html" do
        specify "without parent" do
          patch api_cause_path(cause), params: {cause: {name: "New Name"}}.to_json, headers: content_type_json
          expect(cause.reload.name).to eq "New Name"
          expect(response).to have_http_status(302)
          expect(response).to redirect_to(api_cause_path(cause))
          expect(flash[:notice]).to eq "Cause was successfully updated."
        end

        specify "with parent" do
          parent = create :cause
          patch api_cause_path(cause), params: {cause: {name: "New Name", parent_id: parent.id}}.to_json, headers: content_type_json
          expect(cause.reload.name).to eq "New Name"
          expect(cause.reload.parent_id).to eq parent.id
          expect(response).to have_http_status(302)
          expect(response).to redirect_to(api_cause_path(cause))
          expect(flash[:notice]).to eq "Cause was successfully updated."
        end
      end

      specify "format json" do
        patch(
          api_cause_path(cause),
          params: {cause: {name: "New Name"}}.to_json,
          headers: content_type_json.merge(accept_json)
        )
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to eq({"id"=>cause.id,
                                                 "parent_id"=>cause.parent_id,
                                                 "name"=>"New Name",
                                                 "full_name"=>"New Name",
                                                 "description"=>nil,
                                                 "created_at"=>"1970-01-01T00:00:37.000Z",
                                                 "children" => [],
                                                 "url"=>"http://www.example.com/api/v1/causes/#{cause.id}.json"})
      end
    end
  end

  describe "create: POST /api/v1/causes" do
    it "redirects for unauthenticated folks" do
      post api_causes_path
      expect(response).to have_http_status(302)
      expect(response.body).to include("example.com" + new_user_session_path + '"')
    end

    specify "redirects for authenticated non-admin users" do
      sign_in user
      post api_causes_path, params: {cause: {name: "foobar"}}.to_json, headers: content_type_json
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq "You are not authorized to access this page."
    end

    context "works for admins" do
      before { sign_in admin }

      specify "unless the parent does not exist" do
        c = create(:cause)
        c_id = c.id
        c.destroy
        expect {
          post(
            api_causes_path,
            params: {cause: {name: "foo", parent_id: c_id}}.to_json,
            headers: content_type_json
          )
        }.to change(Cause, :count).by(0)
        expect(response.body).to eq "{\"parent_id\":[\"Parent does not exist\"]}"
        expect(response).to have_http_status(422)
      end

      specify "and unless the name is empty" do
        expect {
          post api_causes_path, params: {cause: {name: ""}}.to_json, headers: content_type_json
        }.to change(Cause, :count).by(0)
        expect(response.body).to eq "{\"name\":[\"can't be blank\"]}"
        expect(response).to have_http_status(422)
      end

      specify "and unless the parent id is bad" do
        post(
          api_causes_path,
          params: {cause: {name: "a cause", parent_id: "foo"}}.to_json,
          headers: content_type_json.merge(accept_json)
        )
        expect(response).to have_http_status(422)
        expect(response.body).to eq "{\"parent_id\":[\"Parent does not exist\"]}"
      end

      specify "format html" do
        post api_causes_path, params: {cause: {name: "foobar"}}.to_json, headers: content_type_json
        expect(Cause.last.name).to eq "foobar"
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(api_cause_url(Cause.last))
      end

      context "format json" do
        context "creating a cause, not a relationship to a charity" do
          specify "without parent" do
            post(
              api_causes_path,
              params: {cause: {name: "a cause"}}.to_json,
              headers: content_type_json.merge(accept_json)
            )
            expect(response).to have_http_status(201)
            cause = Cause.last
            expect(JSON.parse(response.body)).to eq({"id"=>cause.id,
                                                     "parent_id"=>cause.parent_id,
                                                     "name"=>"a cause",
                                                     "full_name"=>"a cause",
                                                     "description"=>nil,
                                                     "created_at"=>"1970-01-01T00:00:37.000Z",
                                                     "children" => [],
                                                     "url"=>"http://www.example.com/api/v1/causes/#{cause.id}.json"})
          end

          specify "with parent" do
            parent = create :cause
            post(
              api_causes_path,
              params: {cause: {name: "a cause", parent_id: "#{parent.id}"}}.to_json,
              headers: content_type_json.merge(accept_json)
            )
            expect(response).to have_http_status(201)
            cause = Cause.last
            expect(cause.parent_id).to eq parent.id
            expect(JSON.parse(response.body)).to eq({"id"=>cause.id,
                                                     "parent_id"=>parent.id,
                                                     "name"=>"a cause",
                                                     "full_name"=>"#{parent.name}/a cause",
                                                     "description"=>nil,
                                                     "created_at"=>"1970-01-01T00:00:37.000Z",
                                                     "children" => [],
                                                     "url"=>"http://www.example.com/api/v1/causes/#{cause.id}.json"})
          end
        end

        context "linking a cause to a charity" do
          let(:charity) { create :charity }

          specify "works" do
            other_cause = create :cause
            charity.causes << other_cause
            second_cause = create :cause, name: "second cause"
            post(
              "/api/v1/charities/#{charity.id}/causes.json",
              params: {cause: {id: second_cause.id.to_s}}.to_json,
              headers: content_type_json
            )
            expect(charity.reload.causes.sort).to eq [other_cause, second_cause].sort
            expect(response).to have_http_status(204)
            expect(response.body).to eq ""
          end

          specify "unless no id is specified" do
            post(
              "/api/v1/charities/#{charity.id}/causes.json",
              params: {cause: {}}.to_json,
              headers: content_type_json
            )
            expect(response).to have_http_status(422)
            expect(response.body).to eq "{\"cause\":\"is required\"}"
          end

          specify "unless bad id is specified" do
            post(
              "/api/v1/charities/#{charity.id}/causes.json",
              params: {cause: {id: "foo"}}.to_json,
              headers: content_type_json
            )
            expect(response).to have_http_status(422)
            expect(response.body).to eq "{\"cause[:id]\":\"required integer\"}"
          end
        end
      end
    end
  end

  describe "destroy: DELETE /api/v1/causes/:id" do
    let!(:cause) { create :cause }

    context "redirects for unauthenticated folks" do
      specify "deleting the cause" do
        delete api_cause_path(cause)
        expect(response).to have_http_status(302)
        expect(response.body).to include("example.com" + new_user_session_path + '"')
      end

      specify "deleting the relationship" do
        charity = create :charity
        delete "/api/v1/charities/#{charity.id}/causes/#{cause.id}"
        expect(response).to have_http_status(302)
        expect(response.body).to include("example.com" + new_user_session_path + '"')
      end
    end

    context "redirects for authenticated non-admin users" do
      specify "deleting the cause" do
        sign_in user
        delete api_cause_path(cause)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq "You are not authorized to access this page."
      end

      specify "deleting the relationship" do
        charity = create :charity
        sign_in user
        delete "/api/v1/charities/#{charity.id}/causes/#{cause.id}"
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq "You are not authorized to access this page."
      end
    end

    context "works for admins" do
      before { sign_in admin }

      specify "unless the cause does not exist" do
        c = create(:cause)
        path = api_cause_path(c)
        expect {
          c.destroy
        }.to change(Cause, :count).by(-1)
        expect {
          delete path, headers: accept_json
        }.to change(Cause, :count).by(0)
        expect(response).to have_http_status(404)
        expect(response.body).to eq "{\"error\":\"Couldn't find Cause with 'id'=#{c.id}\"}"
      end

      specify "format html" do
        delete api_cause_path(cause)
        expect(response).to redirect_to(api_causes_url)
        expect(Cause.find_by(id: cause.id)).to be nil
      end

      context "format json" do
        specify "deleting a relationship" do
          charity = create :charity
          charity.causes << cause
          expect(cause.reload.charities).to eq [charity]
          expect {
            delete(
              "/api/v1/charities/#{charity.id}/causes/#{cause.id}",
              headers: content_type_json.merge(accept_json)
            )
          }.to change(Cause, :count).by(0)
          expect(response).to have_http_status(204)
          expect(charity.reload.causes).to eq []
        end

        specify "deleting a leaf" do
          expect {
            delete api_cause_path(cause), headers: content_type_json.merge(accept_json)
          }.to change(Cause, :count).by(-1)
          expect(response).to have_http_status(204)
          expect(Cause.find_by(id: cause.id)).to be nil
        end

        specify "deleting a non-leaf" do
          c0 = create(:cause, parent_id: cause.id)
          c1 = create(:cause, parent_id: c0.id)
          c2 = create(:cause, parent_id: c0.id)
          not_deleted_cause = create(:cause)
          charity = create(:charity)
          charity.causes << c2
          charity.causes << not_deleted_cause
          expect {
            delete api_cause_path(cause), headers: content_type_json.merge(accept_json)
          }.to change(Cause, :count).by(-4)
          expect(response).to have_http_status(204)
          [cause, c0, c1, c2].each do |c|
            expect(Cause.find_by(id: c.id)).to be nil
          end
          charity = charity.reload
          expect(charity.causes).to eq [not_deleted_cause]
          charity.causes << create(:cause)
          expect(charity.reload.causes.size).to eq 2
        end
      end
    end
  end

end
