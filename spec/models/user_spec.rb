require 'rails_helper'

RSpec.describe User, type: :model do

  it { should validate_presence_of :token }
  it { should validate_presence_of :email }
  it { should validate_presence_of :secret }
  it { should validate_presence_of :account_id }

  it "generates a token & secret on create" do
    account = FactoryGirl.create(:account)
    u = User.create(FactoryGirl.attributes_for(:user).merge(account: account))
    expect(u.token).to_not be_nil
    expect(u.secret).to_not be_nil
  end

  it "returns a token on generate" do
    expect(User.generate_token(6).length).to eq(6)
  end

  it "validates token" do
    u = FactoryGirl.create(:user)
    expect(u.validate(u.generate_otp)).to eq(true)
  end

  it "does not validate invalid token" do
    u = FactoryGirl.create(:user)
    expect(u.validate("000000")).to_not eq(true)
  end

  it "sends an sms with the token" do
    u = FactoryGirl.create(:user)

    expect(u).to receive(:generate_otp).
      and_return("000000")

    expect(u.twilio_client.account.messages).to receive(:create).
      with({
        from: "+#{u.twilio_client.default_from}",
        to:   "+#{u.phone}",
        body: "code: 000000"
      }).
      and_return(true)

    u.send_sms
  end

  it "responds with a url to a qr_code" do
    u = FactoryGirl.create(:user)
    expect(u.qr_url).to eq("/qr/#{u.token}.png")
  end

  context "when twilio fails" do
    after :each do
      sleep 1 # Twilio has a rate limit
    end

    # +15005550001	This phone number is invalid.	21212
    it "catches Twilio error 21212 properly" do
      u = FactoryGirl.create(:user)
      expect(u.twilio_client).to receive(:default_from).and_return("15005550001")

      expect(u.send_sms[0]).to eq(false)
    end

    # +15005550003	Your account doesn't have the international permissions necessary to SMS this number.	21408
    it "catches Twilio error 21408 properly" do
      expect(FactoryGirl.create(:user, phone: "15005550003").send_sms[0]).to eq(false)
    end
  end
end
