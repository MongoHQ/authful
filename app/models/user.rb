class User
  include Mongoid::Document
  include Mongoid::Timestamps

  include Rails.application.routes.url_helpers

  field :token, type: String, default: ->{ User.generate_token }
  field :email, type: String
  field :phone, type: String
  field :fallback_phone, type: String
  field :secret, type: String, default: ->{ User.generate_token }
  field :recovery_codes, type: Array, default: []
  field :qr_expiration, type: Time, default: ->{ Time.now }

  belongs_to :account

  validates :token, presence: true, uniqueness: { scope: :account_id }
  validates :email, presence: true, uniqueness: { scope: :account_id }
  validates :phone, uniqueness: { allow_blank: true, scope: :account_id }, phone: { allow_blank: true, possible: true }
  validates :fallback_phone, phone: { allow_nil: true, possible: true }
  validates :secret, presence: true
  validates :account_id, presence: true

  def activate_qr_code
    self.update_attributes(qr_expiration: 5.minutes.from_now)
  end

  def deactivate_qr_code
    self.update_attributes(qr_expiration: 1.second.ago)
  end

  def sms_user?
    self.phone.present?
  end

  def enrollment_type
    if sms_user?
      "sms"
    else
      "app"
    end
  end

  def self.generate_token(length = 16)
    ROTP::Base32.random_base32(length)
  end

  def validate(token)
    totp = ROTP::TOTP.new(self.secret)
    valid_window = 5.minutes # window of time to accept valid codes
    (-valid_window .. valid_window).step(30).map(&:to_i).any?{|t| totp.verify(token, t.seconds.ago)}
  end

  def generate_recovery_codes
    update_attributes(recovery_codes: 10.times.map{ SecureRandom.hex(5) })
  end

  def validate_recovery_code(code)
    if recovery_codes.delete(code.gsub('-', ''))
      save!
      true
    else
      false
    end
  end

  def generate_otp
    totp = ROTP::TOTP.new(self.secret)
    totp.now.to_s.rjust(6, "0")
  end

  def send_sms(fallback = false)
    $twilio.account.messages.create(
      :from => "+#{$twilio_default_from}",
      :to => "+#{fallback ? self.fallback_phone : self.phone}",
      :body => "code: #{self.generate_otp}"
    )

    [true, "SMS message sent with OTP token."]
  rescue Twilio::REST::RequestError
    [false, "Message did not send. Twilio returned error code #{$!.code}; message: #{$!.message}"]
  rescue Twilio::REST::ServerError
    [false, "Message did not send. Unknown messaging error with Twilio."]
  end

  def send_fallback_sms(welcome = false)
    if welcome
      $twilio.account.messages.create(
        :from => "+#{$twilio_default_from}",
        :to => "+#{self.fallback_phone}",
        :body => "This is a confirmation that you configured this number as your MongoHQ two-factor authentication fallback number."
      )

      [true, "SMS message sent with welcome message."]
    else
      self.send_sms(true)
    end

  rescue Twilio::REST::RequestError
    [false, "Message did not send. Twilio returned error code #{$!.code}; message: #{$!.message}"]
  rescue Twilio::REST::ServerError
    [false, "Message did not send. Unknown messaging error with Twilio."]
  end

  def qr_code
    qr_size = 6
    qr = nil

    # since RQR won't autosize we have to start small and catch errors and resize.
    while qr == nil && qr_size < 15
      begin
        qr = RQRCode::QRCode.new(URI.encode("otpauth://totp/#{self.email}?secret=#{self.secret}&issuer=#{self.account.name}"), :size => qr_size)
      rescue RQRCode::QRCodeRunTimeError
        qr_size += 1
      end
    end

    return qr.to_img.resize(250,250).to_string
  end

  def qr_url
    qr_code_path(id: self.token)
  end
end
