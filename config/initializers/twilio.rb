if Rails.env == "test"
  TWILIO_SID = "ACc511e5b1b1224b8565168bb9be0fb2b2"
  TWILIO_TOKEN = "568a74c895efaf14f2792aa70ac2dba8"
  TWILIO_FROM = "15005550006"
else
  TWILIO_SID = ENV["TWILIO_SID"]
  TWILIO_TOKEN = ENV["TWILIO_TOKEN"]
  TWILIO_FROM = ENV["TWILIO_FROM"]
end

$twilio = Twilio::REST::Client.new TWILIO_SID, TWILIO_TOKEN
$twilio_default_from = TWILIO_FROM
