require 'test_helper'

class SubnetsHelperTest < ActionView::TestCase
  include SubnetsHelper

  let(:ipam_proxy) do
    FactoryBot.create(:smart_proxy,
      :features => [FactoryBot.create(:feature, :name => 'External IPAM')])
  end

  test "external_ipam? method should return true for external ipam subnets" do
    ipam_subnet = FactoryBot.create(:subnet,
      :ipam => "External IPAM",
      :network => '100.25.25.0',
      :mask => '255.255.255.0',
      :externalipam => ipam_proxy)
    assert external_ipam?(ipam_subnet)
  end

  test "external_ipam? method should return false for non external ipam subnets" do
    non_ipam_subnet = FactoryBot.create(:subnet,
      :ipam => "None",
      :network => '100.25.25.0',
      :mask => '255.255.255.0')
    refute external_ipam?(non_ipam_subnet)
  end
end
