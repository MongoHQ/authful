require 'spec_helper'

describe QrController do
  before :each do
    @user = FactoryGirl.create(:user)
  end

  it "show show a qr code for a person" do
    @user.update_attributes(qr_expiration: 3.minutes.since)

    get :show, id: @user.token

    response.status.should eq(200)
    response.content_type.should eq("image/png")
  end

  it "should not show qr code for unknown person" do
    get :show, id: @user.token

    response.status.should eq(404)
  end

  it "should not show qr code after time" do
    get :show, id: @user.token

    response.status.should eq(404)
  end
end
