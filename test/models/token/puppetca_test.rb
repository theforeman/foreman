require 'test_helper'

class Token::PuppetcaTest < ActiveSupport::TestCase
  should validate_uniqueness_of(:value)

  let(:host_without_token) { FactoryBot.create(:host) }
  let(:host) { FactoryBot.create(:host, :with_puppetca_token) }

  test "a host can create a puppetca-token" do
    assert_instance_of Token::Puppetca, host.puppetca_token
    assert_equal Token::Puppetca.first.host_id, host.id
  end

  test "a tokens value is not overriden on save" do
    host_without_token.create_puppetca_token(:value => 'aaaa')
    assert_equal Token::Puppetca.first.value, 'aaaa'
  end

  test "a tokens value is generated on save" do
    host
    assert_instance_of String, Token::Puppetca.first.value
    assert Token::Puppetca.first.value.length > 12
  end
end
