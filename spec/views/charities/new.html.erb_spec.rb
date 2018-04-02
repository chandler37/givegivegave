require 'rails_helper'

RSpec.describe "charities/new", type: :view do
  before(:each) do
    assign(:charity, Charity.new(
      :name => "MyString",
      :ein => "MyString",
      :description => "MyText",
      :score_overall => 1.5,
      :score_financial => 1.5,
      :score_accountability => 1.5,
      :stars_overall => "",
      :stars_financial => "",
      :stars_accountability => ""
    ))
  end

  it "renders new charity form" do
    render

    assert_select "form[action=?][method=?]", charities_path, "post" do

      assert_select "input[name=?]", "charity[name]"

      assert_select "input[name=?]", "charity[ein]"

      assert_select "textarea[name=?]", "charity[description]"

      assert_select "input[name=?]", "charity[score_overall]"

      assert_select "input[name=?]", "charity[score_financial]"

      assert_select "input[name=?]", "charity[score_accountability]"

      assert_select "input[name=?]", "charity[stars_overall]"

      assert_select "input[name=?]", "charity[stars_financial]"

      assert_select "input[name=?]", "charity[stars_accountability]"
    end
  end
end
