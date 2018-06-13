require 'test_helper'

class Token::BuildTest < ActiveSupport::TestCase
  should validate_presence_of(:expires)

  let(:host) { FactoryBot.create(:host) }

  test "a host can create a token" do
    host.create_token(:value => "aaaaaa", :expires => Time.now.utc)
    assert_equal Token.first.value, "aaaaaa"
    assert_equal Token.first.host_id, host.id
  end

  test "a host can delete its token" do
    host.create_token(:value => 'aaaaaa', :expires => Time.now.utc + 1.minute)
    assert_instance_of Token::Build, host.token
    host.token = nil
    assert Token.where(:value => 'aaaaaa', :host_id => host.id).empty?
  end

  test "a host cannot delete tokens for other hosts" do
    host2 = FactoryBot.create(:host)
    host.create_token(:value => 'aaaaaa', :expires => Time.now.utc + 1.minute)
    host2.create_token(:value => 'bbbbbb', :expires => Time.now.utc + 1.minute)
    assert_equal Token.all.size, 2
    host.token = nil
    assert_equal Token.all.size, 1
  end

  test "not all expired tokens should be removed" do
    host2 = FactoryBot.create(:host)
    host.create_token(:value => 'aaaaaa', :expires => Time.now.utc + 1.minute)
    host2.create_token(:value => 'bbbbbb', :expires => Time.now.utc - 1.minute)
    assert_equal 2, Token.count
    host.expire_token
    assert_equal 1, Token.count
  end
end
