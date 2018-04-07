require 'rails_helper'

RSpec.describe "charities/index", type: :view do
  include Devise::Test::ControllerHelpers
  before(:each) do
    assign(:charities, [
      Charity.create!(
        :name => "Name",
        :ein => "Ein1",
        :description => "MyText",
        :score_overall => 2.5,
        :stars_overall => 3,
      ),
      Charity.create!(
        :name => "Name",
        :ein => "Ein-2",
        :description => "MyText",
        :score_overall => 2.5,
        :stars_overall => 3,
      )
    ])
  end

  it "renders a list of charities" do
    # TODO(chandler): test that admins can manage charities but non-admins cannot.
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "ein1".to_s, :count => 1
    assert_select "tr>td", :text => "ein2".to_s, :count => 1
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 2.5.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 4
  end
end
