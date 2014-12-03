require 'test_helper'

class TokenTest < ActiveSupport::TestCase

  test "a token has a value" do
    t = Token.new
    assert !t.save
  end

  test "a token has an expiry" do
    t = Token.new :value => "aaaaaa"
    assert !t.save
  end

  test "a token is assigned to a host" do
    t = Token.new :value => "aaaaaa", :expires => Time.now
    assert !t.save
  end

  test "a token expires when set to expire" do
    expiry = Time.now
    t      = Token.new :value => "aaaaaa", :expires => expiry
    assert_equal t.expires, expiry
  end

  test "a host can create a token" do
    h = FactoryGirl.create(:host)
    h.create_token(:value => "aaaaaa", :expires => Time.now)
    assert_equal Token.first.value, "aaaaaa"
    assert_equal Token.first.host_id, h.id
  end

  test "a host can delete its token" do
    h = FactoryGirl.create(:host)
    h.create_token(:value => "aaaaaa", :expires => Time.now + 1.minutes)
    assert_instance_of Token, h.token
    h.token=nil
    assert Token.where(:value => "aaaaaa", :host_id => h.id).empty?
  end

  test "a host cannot delete tokens for other hosts" do
    h1 = FactoryGirl.create(:host)
    h2 = FactoryGirl.create(:host)
    h1.create_token(:value => "aaaaaa", :expires => Time.now + 1.minutes)
    h2.create_token(:value => "bbbbbb", :expires => Time.now + 1.minutes)
    assert_equal Token.all.size, 2
    h1.token=nil
    assert_equal Token.all.size, 1
  end

  test "not all expired tokens should be removed" do
    h1 = FactoryGirl.create(:host)
    h2 = FactoryGirl.create(:host)
    h1.create_token(:value => "aaaaaa", :expires => Time.now + 1.minutes)
    h2.create_token(:value => "bbbbbb", :expires => Time.now - 1.minutes)
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
