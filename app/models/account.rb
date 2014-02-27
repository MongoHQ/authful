class Account
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :token, type: String, default: ->(){ Account.generate_token }

  has_many :users

  validates :name, :presence => true
  validates :token, :presence => true, :uniqueness => true

  def self.generate_token(length = 16)
    ROTP::Base32.random_base32
  end
end
