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
end
