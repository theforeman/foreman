class Token::Puppetca < ::Token
  validates :value, uniqueness: true
end
