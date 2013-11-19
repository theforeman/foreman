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

  test "a token is assigned to a system" do
    t = Token.new :value => "aaaaaa", :expires => Time.now
    assert !t.save
  end

  test "a token expires when set to expire" do
    expiry = Time.now
    t      = Token.new :value => "aaaaaa", :expires => expiry
    assert_equal t.expires, expiry
  end

  test "a system can create a token" do
    h = systems(:one)
    h.create_token(:value => "aaaaaa", :expires => Time.now)
    assert_equal Token.first.value, "aaaaaa"
    assert_equal Token.first.system_id, h.id
  end

  test "a token can be matched to a system" do
    h = systems(:one)
    h.create_token(:value => "aaaaaa", :expires => Time.now + 1.minutes)
    assert_equal h, System.for_token("aaaaaa").first
  end

  test "a system can delete its token" do
    h = systems(:one)
    h.create_token(:value => "aaaaaa", :expires => Time.now + 1.minutes)
    assert_instance_of Token, h.token
    h.token=nil
    assert Token.where(:value => "aaaaaa", :system_id => h.id).empty?
  end

  test "a system cannot delete tokens for other systems" do
    h1 = systems(:one)
    h2 = systems(:two)
    h1.create_token(:value => "aaaaaa", :expires => Time.now + 1.minutes)
    h2.create_token(:value => "bbbbbb", :expires => Time.now + 1.minutes)
    assert_equal Token.all.size, 2
    h1.token=nil
    assert_equal Token.all.size, 1
  end

  test "all expired tokens should be removed" do
    h1 = systems(:one)
    h2 = systems(:two)
    h1.create_token(:value => "aaaaaa", :expires => Time.now + 1.minutes)
    h2.create_token(:value => "bbbbbb", :expires => Time.now - 1.minutes)
    assert_equal Token.count, 2
    h1.expire_tokens
    assert_equal 0, Token.count
  end

end
