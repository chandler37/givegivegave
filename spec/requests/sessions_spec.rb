RSpec.describe "Sessions" do
  it "signs user in and out" do
    user = User.create!(email: "user@example.org", password: "very-secret")

    sign_in user
    expect {
      get rails_admin.dashboard_path
    }.to raise_error UncaughtThrowError # devise's :confirmable trait at work
    sign_out user

    user.update_attributes!(confirmed_at: Time.at(37))
    sign_in user
    get rails_admin.dashboard_path
    expect(controller.current_user).to eq(user)

    sign_out user
    get rails_admin.dashboard_path
    expect(controller).to be_a ::Devise::FailureApp
  end
end
