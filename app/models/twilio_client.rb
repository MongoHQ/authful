class TwilioClient
  extend Forwardable

  attr_reader :default_from
  def_delegator :@twilio, :account

  def initialize
    @twilio = Twilio::REST::Client.new ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"]
    @default_from = ENV["TWILIO_FROM"]
  end
end
