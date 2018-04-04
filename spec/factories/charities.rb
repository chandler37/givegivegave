FactoryBot.define do
  factory :charity do
    sequence(:name) { |n| "Charity#{n}" }
    sequence(:ein) { |n| "53-#{n}" }
  end
end
