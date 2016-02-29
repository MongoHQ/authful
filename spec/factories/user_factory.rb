FactoryGirl.define do
  factory :user do
    sequence(:email) { |i| "email-#{i}@example.com" }
    sequence(:phone) { |i| "1205924#{1000 + i}" }
    account
  end
end
