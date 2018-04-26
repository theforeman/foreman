class Token::Puppetca < ::Token
  validates :value, uniqueness: true

  before_validation :generate_token, on: :create, prepend: true, unless: ->(token) { token.value.present? }

  private

  def generate_token
    loop do
      self.value = SecureRandom.urlsafe_base64
      break unless self.class.find_by(value: value)
    end
  end
end
