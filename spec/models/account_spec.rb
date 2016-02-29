require 'rails_helper'

RSpec.describe Account, type: :model do

  it { should validate_presence_of :name }
  it { should validate_presence_of :token }

  it "has many users" do
    expect(Account.new).to respond_to(:users)

    account = FactoryGirl.create(:account)
    FactoryGirl.create(:user, account: account)
    expect(account.users.count).to eq(1)
  end

  it "generates token when created" do
    a = Account.create!(name: "bob")
    expect(a.token).to_not be_nil
  end
end
