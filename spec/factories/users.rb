FactoryBot.define do
  factory :user do
    sequence(:email) { |n|  "test+#{n}@testy.mctestersons" }
    password "very-secret"

    factory :admin, class: User do
      admin true
    end
  end
end
