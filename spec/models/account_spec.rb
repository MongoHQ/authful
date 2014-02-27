require 'spec_helper'

describe Account do

  it { should validate_presence_of :name }
  it { should validate_presence_of :token }

  it "has many users" do
    Account.new.should respond_to(:users)

    account = create(:account)
    create(:user, account: account)
    account.users.count.should eq(1)
  end

  it "generates token when created" do
    a = Account.create!(name: "bob")
    a.token.should_not be_nil
  end
end
