class JwtSecret < ApplicationRecord
  include Encryptable

  encrypts :token

  belongs_to :user, inverse_of: :jwt_secret

  validates :token, uniqueness: true
  validates :user, presence: true

  before_create :generate_token, prepend: true, :unless => proc { |j| j.token.present? }

  private

  def generate_token
    loop do
      self.token = SecureRandom.base64
      break unless JwtSecret.find_by(token: token)
    end
  end
end
