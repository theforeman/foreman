class Token::PuppetCA < ::Token
  validates :value, uniqueness: true
end
