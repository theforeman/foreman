require 'test_helper'

class SubnetTest < ActiveSupport::TestCase
  test 'should be cast to Subnet::Ipv4 if no type is set' do
    subnet = Subnet.new
    assert_equal Subnet::Ipv4, subnet.class
  end

  test 'should be cast to Subnet::Ipv4 if type is set' do
    subnet = Subnet.new(:type => 'Subnet::Ipv4')
    assert_equal Subnet::Ipv4, subnet.class
  end

  test 'child class should not be cast to default sti class even if no type is set' do
    class Subnet::Test < Subnet; end
    subnet = Subnet::Test.new
    assert_equal Subnet::Test, subnet.class
  end
end
