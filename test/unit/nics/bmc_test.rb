require 'test_helper'

class BMCTest < ActiveSupport::TestCase
  test 'lowercase IPMI provider string gets set to uppercase' do
    host = FactoryGirl.build(:host, :managed)
    assert FactoryGirl.build(:nic_bmc, :host => host, :provider => 'ipmi').valid?
  end
end
