require 'rails_helper'

RSpec.describe Cause, type: :model do
  it "builds" do
    Cause.create!(name: "f"*10101)
    expect(Cause.create!(name: "f", description: "g"*10101).description).to eq("g"*10101)
  end

  it "fails to build without a name" do
    expect {
      Cause.create!
    }.to raise_error ActiveRecord::RecordInvalid
    expect {
      Cause.create!(name: "")
    }.to raise_error ActiveRecord::RecordInvalid
    expect {
      Cause.create!(name: nil)
    }.to raise_error ActiveRecord::RecordInvalid
  end

  context "has a factory" do
    let!(:cause) { create :cause }
    it do
      expect(cause.name).to be_present
      expect(cause.description).to be nil
      cause.reload
    end
  end

  context "parent/children" do
    let!(:parent) { create :cause }
    let!(:child1) { create :cause, parent_id: parent.id }
    let!(:child2) { create :cause, parent_id: parent.id }
    
    it "works" do
      expect(parent.parent_id).to be nil
      expect(child1.parent_id).to eq parent.id
      expect(parent.children.sort).to eq [child1, child2].sort
    end
  end
end
