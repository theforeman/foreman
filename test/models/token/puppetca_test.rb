require 'test_helper'

class Token::PuppetcaTest < ActiveSupport::TestCase
  should validate_uniqueness_of(:value)

  let(:host) { FactoryBot.create(:host) }

  test "a host can create a puppetca-token" do
    host.create_puppetca_token value: 'foo.bar.baz'
    assert_instance_of Token::Puppetca, host.puppetca_token
    assert_equal Token::Puppetca.first.host_id, host.id
    assert_equal 'foo.bar.baz', host.puppetca_token.value
  end

  test "a host can delete its puppetca-token" do
    host.create_puppetca_token value: 'aaaa'
    assert_equal host.puppetca_token.value, 'aaaa'
    host.puppetca_token = nil
    assert_nil host.puppetca_token
    assert_equal Token::Puppetca.all, []
  end
end
