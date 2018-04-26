require 'test_helper'

class TokenTest < ActiveSupport::TestCase
  should validate_presence_of(:value)
  should validate_presence_of(:host_id)

  test "token jail test" do
    allowed = [:host, :value, :expires, :nil?]
    allowed.each do |m|
      assert Token::Jail.allowed?(m), "Method #{m} is not available in Token::Jail while should be allowed."
    end
  end
end
