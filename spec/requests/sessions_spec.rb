RSpec.describe "Sessions" do
  it "signs user in and out" do
    user = User.create!(email: "user@example.org", password: "very-secret")

    sign_in user
    get rails_admin.dashboard_path
    expect(controller.current_user).to eq(user)

    sign_out user
    get rails_admin.dashboard_path
    expect(controller).to be_a ::Devise::FailureApp
  end
end
