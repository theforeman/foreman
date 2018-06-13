class Token::Build < ::Token
  validates :expires, presence: true
end
