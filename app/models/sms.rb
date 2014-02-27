class Sms

  def send_activation_code(target_phone)
    client.account.sms.messages.create(
      from: "+14152879814",
      to: target_phone.gsub(/\D/, ''),
      body: "This is your activation code:"
    )
  end

  private

  def client
    @client ||= Twilio::REST::Client.new(TWILIO_SID, TWILIO_AUTH_TOKEN)
  end
end