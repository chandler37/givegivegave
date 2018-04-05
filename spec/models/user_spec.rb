require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { User.create!(email: "f@a.b", password: "f"*8) }
  specify "can be disabled without being deleted banning that email address for life" do
    # To disable a user, use rails_admin.
    expect(user.active_for_authentication?).to be_truthy
    user.update_attributes!(disabled_at: Time.now)
    expect(user.reload.disabled_at).to be_truthy
    expect(user.active_for_authentication?).to be_falsy
  end
  specify "has an email" do
    expect(user.reload.email).to eq "f@a.b"
  end
  specify "requires a lengthy password" do
    expect {
      create :user, password: "f"*7
    }.to raise_error ActiveRecord::RecordInvalid, /Password is too short/
  end
  specify "requires a not-too-lengthy password" do
    expect {
      create :user, password: "f"*72
    }.to raise_error ActiveRecord::RecordInvalid, /Password is too long/
  end
  specify "allows the lengthiest password bcrypt supports" do
    u = create :user, password: "f"*71
    expect(u.valid_password?("f"*72)).to be_falsy
    expect(u.valid_password?("f"*71)).to be_truthy
    expect(u.valid_password?("f"*70)).to be_falsy
  end
  context "allows passwords so lengthy that bcrypt ignores part of them" do
    it "does not know about 72 byte limit" do
      u = create :user, email: user.email + "c", password: "\u{1f4a9}"*(72/4+1)
      expect(u.reload.valid_password?("\u{1f4a9}"*(72/4))).to be_truthy
      expect(u.reload.valid_password?("\u{1f4a9}"*(72/4-1))).to be_falsy
      # TODO(chandler37): fix this
    end
  end
  specify "requires email to be unique" do
    expect {
      create :user, email: user.email
    }.to raise_error ActiveRecord::RecordInvalid, /Email has already been taken/
    expect {
      create :user, email: "F@a.b"
    }.to raise_error ActiveRecord::RecordInvalid, /Email has already been taken/
  end
  specify "stores a bcrypt hash of the password, not the plaintext password" do
    result = ActiveRecord::Base.connection.execute(
      'SELECT encrypted_password FROM users LIMIT 1'
    )
    expect(result[0]["encrypted_password"]).to match /\A\$2a\$04\$/
  end
  specify "has the columns we expect, none of which have a password" do
    result = ActiveRecord::Base.connection.execute(
      'SELECT * FROM users LIMIT 1'
    )
    expect(result[0].keys.sort).to eq %w{admin confirmation_sent_at confirmation_token confirmed_at created_at current_sign_in_at current_sign_in_ip disabled_at email encrypted_password failed_attempts id last_sign_in_at last_sign_in_ip locked_at remember_created_at reset_password_sent_at reset_password_token sign_in_count unconfirmed_email unlock_token updated_at}
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
