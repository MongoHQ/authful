class QrController < ApplicationController
  def show
    user = User.where(token: params[:id].to_s).first

    if user && user.qr_expiration > Time.now
      user.deactivate_qr_code
      send_data user.qr_code, type: 'image/png', disposition: 'inline'
    else
      render text: "Not Found", status: "404"
    end
  end
end
