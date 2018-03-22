require 'test_helper'

class TokenTest < ActiveSupport::TestCase
  should validate_presence_of(:value)
  should validate_presence_of(:expires)
  should validate_presence_of(:host_id)

  test "a host can create a token" do
    h = FactoryBot.create(:host)
    h.create_token(:value => "aaaaaa", :expires => Time.now.utc)
    assert_equal Token.first.value, "aaaaaa"
    assert_equal Token.first.host_id, h.id
  end

  test "a host can delete its token" do
    h = FactoryBot.create(:host)
    h.create_token(:value => "aaaaaa", :expires => Time.now.utc + 1.minute)
    assert_instance_of Token, h.token
    h.token=nil
    assert Token.where(:value => "aaaaaa", :host_id => h.id).empty?
  end

  test "a host cannot delete tokens for other hosts" do
    h1 = FactoryBot.create(:host)
    h2 = FactoryBot.create(:host)
    h1.create_token(:value => "aaaaaa", :expires => Time.now.utc + 1.minute)
    h2.create_token(:value => "bbbbbb", :expires => Time.now.utc + 1.minute)
    assert_equal Token.all.size, 2
    h1.token=nil
    assert_equal Token.all.size, 1
  end

  test "not all expired tokens should be removed" do
    h1 = FactoryBot.create(:host)
    h2 = FactoryBot.create(:host)
    h1.create_token(:value => "aaaaaa", :expires => Time.now.utc + 1.minute)
    h2.create_token(:value => "bbbbbb", :expires => Time.now.utc - 1.minute)
    assert_equal 2, Token.count
    h1.expire_token
    assert_equal 1, Token.count
  end

  test "token jail test" do
    allowed = [:host, :value, :expires, :nil?]
    allowed.each do |m|
      assert Token::Jail.allowed?(m), "Method #{m} is not available in Token::Jail while should be allowed."
    end
  end
end
