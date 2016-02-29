require 'rails_helper'

RSpec.describe QrController, type: :controller do
  before :each do
    @user = FactoryGirl.create(:user)
  end

  it "show show a qr code for a person" do
    @user.update_attributes(qr_expiration: 3.minutes.since)

    get :show, id: @user.token

    expect(response.status).to eq(200)
    expect(response.content_type).to eq("image/png")
  end

  it "should not show qr code for unknown person" do
    get :show, id: @user.token

    expect(response.status).to eq(404)
  end

  it "should not show qr code after time" do
    get :show, id: @user.token

    expect(response.status).to eq(404)
  end
end
