require 'spec_helper'

describe User do

  it { should validate_presence_of :token }
  it { should validate_presence_of :email }
  it { should validate_presence_of :secret }
  it { should validate_presence_of :account_id }

  it "generates a token & secret on create" do
    account = create(:account)
    u = User.create(attributes_for(:user).merge(account: account))
    u.token.should_not be_nil
    u.secret.should_not be_nil
  end

  it "returns a token on generate" do
    User.generate_token(6).length.should eq(6)
  end

  it "validates token" do
    u = create(:user)
    u.validate(u.generate_otp).should eq(true)
  end

  it "does not validate invalid token" do
    u = create(:user)
    u.validate("000000").should_not eq(true)
  end

  it "sends an sms with the token" do
    u = create(:user)

    expect(u).to receive(:generate_otp).
      and_return("000000")

    expect($twilio.account.messages).to receive(:create).
      with({
        from: "+#{$twilio_default_from}",
        to:   "+#{u.phone}",
        body: "code: 000000"
      }).
      and_return(true)

    u.send_sms
  end

  it "responds with a url to a qr_code" do
    u = create(:user)
    u.qr_url.should eq("/qr/#{u.token}.png")
  end

  context "when twilio fails" do
    after :each do
      sleep 1 # Twilio has a rate limit
    end

    # +15005550001	This phone number is invalid.	21212 
    it "catches Twilio error 21212 properly" do
      test_different_send_number("15005550001") do
        create(:user).send_sms[0].should eq(false)
      end
    end

    # +15005550003	Your account doesn't have the international permissions necessary to SMS this number.	21408
    it "catches Twilio error 21408 properly" do
      create(:user, phone: "15005550003").send_sms[0].should eq(false)
    end
  end

  def test_different_send_number(new_number, &block)
    old_number = $twilio_default_from
    $twilio_default_from = new_number
    block.call
    $twilio_default_from = old_number
  end
  
end
