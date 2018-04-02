require 'rails_helper'

RSpec.describe "charities/index", type: :view do
  include Devise::Test::ControllerHelpers
  before(:each) do
    assign(:charities, [
      Charity.create!(
        :name => "Name",
        :ein => "Ein",
        :description => "MyText",
        :score_overall => 2.5,
        :score_financial => 3.5,
        :score_accountability => 4.5,
        :stars_overall => 3,
        :stars_financial => 4,
        :stars_accountability => nil
      ),
      Charity.create!(
        :name => "Name",
        :ein => "Ein",
        :description => "MyText",
        :score_overall => 2.5,
        :score_financial => 3.5,
        :score_accountability => 4.5,
        :stars_overall => 3,
        :stars_financial => 4,
        :stars_accountability => nil
      )
    ])
  end

  it "renders a list of charities" do
    # TODO(chandler): test that admins can manage charities but non-admins cannot.
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Ein".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 2.5.to_s, :count => 2
    assert_select "tr>td", :text => 3.5.to_s, :count => 2
    assert_select "tr>td", :text => 4.5.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 6
  end
end
