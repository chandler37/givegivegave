require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { User.create!(email: "f@a.b", password: "f"*8, password_confirmation: "f"*8) }
  specify "has an email" do
    expect(user.reload.email).to eq "f@a.b"
  end
  specify "requires a lengthy password" do
    expect {
      User.create!(email: "f@a.b", password: "f"*7, password_confirmation: "f"*7)
    }.to raise_error ActiveRecord::RecordInvalid, /Password is too short/
  end
  specify "stores a bcrypt hash of the password, not the plaintext password" do
    result = ActiveRecord::Base.connection.execute(
      'SELECT encrypted_password FROM users LIMIT 1'
    )
    expect(result[0]["encrypted_password"]).to match /\A\$2a\$04\$/
  end
  specify "has the columns we expect" do
    result = ActiveRecord::Base.connection.execute(
      'SELECT * FROM users LIMIT 1'
    )
    expect(result[0].keys.sort).to eq %w{admin confirmation_sent_at confirmation_token confirmed_at created_at current_sign_in_at current_sign_in_ip email encrypted_password failed_attempts id last_sign_in_at last_sign_in_ip locked_at remember_created_at reset_password_sent_at reset_password_token sign_in_count unconfirmed_email unlock_token updated_at}
  end

  context "has a couple of factories" do
    let!(:non_admin) { create :user }
    let!(:admin) { create :admin }
    specify "that are admin if they should be" do
      expect(admin.admin).to eq true
      expect(non_admin.admin).to eq false
    end
  end
end
