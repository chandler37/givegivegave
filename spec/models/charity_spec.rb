require 'rails_helper'

RSpec.describe Charity, type: :model do
  # TODO(chandler37): more tests, e.g. how long can a string (vs. text) be? do
  # we do the right thing with really long names?
  it "builds" do
    Charity.create!(name: "f")
  end

  it "fails to build without a name" do
    expect {
      Charity.create!
    }.to raise_error ActiveRecord::RecordInvalid
    expect {
      Charity.create!(name: "")
    }.to raise_error ActiveRecord::RecordInvalid
    expect {
      Charity.create!(name: nil)
    }.to raise_error ActiveRecord::RecordInvalid
  end

  context "has a factory" do
    let!(:charity) { create :charity }
    it do
      expect(charity.name).to be_present
      charity.reload
    end
  end

  specify "requires ein to be unique" do
    create :charity, ein: "Ab-1 "
    expect {
      create :charity, ein: "ab1"
    }.to raise_error ActiveRecord::RecordInvalid, /Ein has already been taken/
  end

  specify "canonicalizes EIN tax IDs" do
    expect(described_class.canonical_ein(" -13--4 ")).to eq "134"
  end

  specify "has a display EIN" do
    c = create(:charity, ein: "0"*9)
    expect(c.display_ein).to eq "00-0000000"
    expect(c.display_ein_changed?).to eq false
    c.ein = "foo"
    expect(c.display_ein_changed?).to eq true

    c = create(:charity, ein: "1"*8)
    expect(c.display_ein).to eq "01-1111111"
    c = create(:charity, ein: "1"*7)
    expect(c.display_ein).to eq "1"*7
    c = create(:charity, ein: "f")
    expect(c.display_ein).to eq "f"
  end
end
