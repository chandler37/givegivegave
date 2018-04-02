require 'rails_helper'

RSpec.describe "charities/index", type: :view do
  before(:each) do
    assign(:charities, [
      Charity.create!(
        :name => "Name",
        :ein => "Ein",
        :description => "MyText",
        :score_overall => 2.5,
        :score_financial => 3.5,
        :score_accountability => 4.5,
        :stars_overall => "",
        :stars_financial => "",
        :stars_accountability => ""
      ),
      Charity.create!(
        :name => "Name",
        :ein => "Ein",
        :description => "MyText",
        :score_overall => 2.5,
        :score_financial => 3.5,
        :score_accountability => 4.5,
        :stars_overall => "",
        :stars_financial => "",
        :stars_accountability => ""
      )
    ])
  end

  it "renders a list of charities" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Ein".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 2.5.to_s, :count => 2
    assert_select "tr>td", :text => 3.5.to_s, :count => 2
    assert_select "tr>td", :text => 4.5.to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
