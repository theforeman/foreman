require 'test_helper'

class Subnet::ExternalIPAMTest < ActiveSupport::TestCase
  test 'external ipam is supported for IPv4' do
    subnet = FactoryBot.build(:subnet_ipv4)
    assert subnet.supports_ipam_mode?(:external_ipam)
  end

  test 'external ipam is supported for IPv6' do
    subnet = FactoryBot.build(:subnet_ipv6)
    assert subnet.supports_ipam_mode?(:external_ipam)
  end

  test 'subnet with external ipam does not need IP range' do
    subnet = FactoryBot.build(:subnet_ipv4)
    subnet.ipam = IPAM::MODES[:external_ipam]
    refute subnet.ipam_needs_range?
  end
end
