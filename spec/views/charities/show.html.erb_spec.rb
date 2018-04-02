require 'rails_helper'

RSpec.describe "charities/show", type: :view do
  before(:each) do
    @charity = assign(:charity, Charity.create!(
      :name => "Name",
      :ein => "Ein",
      :description => "MyText",
      :score_overall => 2.5,
      :score_financial => 3.5,
      :score_accountability => 4.5,
      :stars_overall => "",
      :stars_financial => "",
      :stars_accountability => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Ein/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/2.5/)
    expect(rendered).to match(/3.5/)
    expect(rendered).to match(/4.5/)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
