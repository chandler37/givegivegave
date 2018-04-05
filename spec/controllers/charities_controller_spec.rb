require 'rails_helper'

# This file was generated by 'rails g scaffold' but has been lovingly
# edited. I'll keep this comment:
#
# "Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem."

RSpec.describe CharitiesController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create :user }
  let(:admin) { create :admin }

  let(:valid_attributes) {
    {name: "a charity"}
  }

  let(:invalid_attributes) {
    {name: ""}
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CharitiesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "returns a success response if you are logged in" do
      charity = Charity.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to redirect_to(new_user_session_url)
      sign_in user
      get :index, params: {}, session: valid_session
      expect(response).to be_success
      sign_out user
      sign_in admin
      get :index, params: {}, session: valid_session
      expect(response).to be_success
    end
  end

  describe "GET #show" do
    let(:charity) { create :charity }
    it "returns a success response if you are logged in" do
      sign_in user
      get :show, params: {id: charity.to_param}, session: valid_session
      expect(response).to be_success
    end
    it "302s if you haven't confirmed your email address" do
      user.update_attributes!(confirmed_at: nil)
      sign_in user
      get :show, params: {id: charity.to_param}, session: valid_session
      expect(response).to redirect_to(new_user_session_url)
    end
  end

  describe "GET #new" do
    it "returns a success response for admins" do
      sign_in admin
      get :new, params: {}, session: valid_session
      expect(response).to be_success
    end
    it "302s if you're not an admin" do
      sign_in user
      get :new, params: {}, session: valid_session
      expect(flash[:alert]).to eq "You are not authorized to access this page."
      expect(response).to redirect_to(root_url)
    end
  end

  describe "GET #edit" do
    let!(:charity) { Charity.create! valid_attributes }
    it "keeps out the great unwashed" do
      sign_in user
      get :edit, params: {id: charity.to_param}, session: valid_session
      expect(flash[:alert]).to eq "You are not authorized to access this page."
      expect(response).to redirect_to(root_url)
    end
    it "is successful for admins" do
      sign_in admin
      get :edit, params: {id: charity.to_param}, session: valid_session
      expect(response).to be_success
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Charity" do
        sign_in admin
        expect {
          post :create, params: {charity: valid_attributes}, session: valid_session
        }.to change(Charity, :count).by(1)
      end

      it "does not create a new Charity unless you are an admin" do
        sign_in user
        expect {
          post :create, params: {charity: valid_attributes}, session: valid_session
          expect(flash[:alert]).to eq "You are not authorized to access this page."
          expect(response).to redirect_to(root_url)
        }.to change(Charity, :count).by(0)
      end

      it "redirects to the created charity" do
        sign_in admin
        post :create, params: {charity: valid_attributes}, session: valid_session
        expect(response).to redirect_to(Charity.last)
      end
    end

    context "with invalid params" do
      it "for admins it returns a success response (i.e. to display the 'new' template)" do
        sign_in admin
        post :create, params: {charity: invalid_attributes}, session: valid_session
        expect(response).to be_success
      end
      it "for non-admins redirects" do
        sign_in user
        post :create, params: {charity: invalid_attributes}, session: valid_session
        expect(flash[:alert]).to eq "You are not authorized to access this page."
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe "PUT #update" do
    let!(:charity) { Charity.create! valid_attributes }

    context "with valid params" do
      let(:new_attributes) {
        {name: "American Red Cross", description: "well-known"}
      }

      it "updates the requested charity" do
        sign_in admin
        put :update, params: {id: charity.to_param, charity: new_attributes}, session: valid_session
        charity.reload
        expect(charity.name).to eq new_attributes[:name]
        expect(charity.description).to eq new_attributes[:description]
      end

      it "redirects for non-admins" do
        sign_in user
        put :update, params: {id: charity.to_param, charity: new_attributes}, session: valid_session
        charity.reload
        expect(charity.name).not_to eq new_attributes[:name]
        expect(flash[:alert]).to eq "You are not authorized to access this page."
        expect(response).to redirect_to(root_url)
      end

      it "redirects to the charity" do
        sign_in admin
        put :update, params: {id: charity.to_param, charity: valid_attributes}, session: valid_session
        expect(response).to redirect_to(charity)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        sign_in admin
        put :update, params: {id: charity.to_param, charity: invalid_attributes}, session: valid_session
        expect(response).to be_success
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested charity" do
      sign_in admin
      charity = Charity.create! valid_attributes
      expect {
        delete :destroy, params: {id: charity.to_param}, session: valid_session
      }.to change(Charity, :count).by(-1)
    end

    it "redirects to the charities list" do
      sign_in admin
      charity = Charity.create! valid_attributes
      delete :destroy, params: {id: charity.to_param}, session: valid_session
      expect(response).to redirect_to(charities_url)
    end

    it "rejects non-admin users" do
      sign_in user
      charity = Charity.create! valid_attributes
      delete :destroy, params: {id: charity.to_param}, session: valid_session
      expect(response).to redirect_to(root_url)
    end

    it "rejects the unauthenticated" do
      charity = Charity.create! valid_attributes
      delete :destroy, params: {id: charity.to_param}, session: valid_session
      expect(response).to redirect_to(new_user_session_url)
    end
  end

end
