require 'test_helper'

class ProxyFeaturesValidatorTest < ActiveSupport::TestCase
  class Validatable
    include ActiveModel::Validations
    validates :proxy, :proxy_features => { :feature => 'DNS' }
    attr_accessor :proxy
  end

  def setup
    @validatable = Validatable.new
  end

  test 'should pass when proxy feature is present' do
    @validatable.proxy = FactoryBot.build(:dns_smart_proxy)
    assert_valid @validatable
  end

  test 'should fail when proxy feature is not present' do
    @validatable.proxy = FactoryBot.build(:dhcp_smart_proxy)
    refute_valid @validatable
    assert_equal ['does not have the DNS feature'], @validatable.errors[:proxy_id]
  end
end
