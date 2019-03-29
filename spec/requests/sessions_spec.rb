RSpec.describe "Sessions" do
  before do
    host! "some.host.or.the.other"
  end

  it "signs user in and out" do
    user = User.create!(email: "user@example.org", password: "very-secret")
    expect(user.reload.confirmed_at).to be nil

    sign_in user
    get rails_admin.dashboard_path
    expect(response).to redirect_to(new_user_session_path)
    sign_out user

    user.update_attributes!(confirmed_at: Time.at(37))
    sign_in user
    get rails_admin.dashboard_path
    expect(response).to redirect_to("http://some.host.or.the.other/")  # TODO(chandler37): Let's disallow all http and redirect to https, though.
  end

  it "allows admins to see the rails_admin dashboard" do
    user = create(:admin)
    sign_in user
    get rails_admin.dashboard_path
    expect(response.body).to match(%r{<title>Site Administration | Givegivegave Admin</title>})
    expect(response.status).to eq 200

    sign_out user
    get rails_admin.dashboard_path
    expect(response).to redirect_to(new_user_session_path)
  end
end
