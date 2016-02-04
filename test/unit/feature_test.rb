require 'test_helper'

class FeatureTest < ActiveSupport::TestCase
  should have_and_belong_to_many(:smart_proxies)
  should validate_presence_of(:name)

  def test_natural_order
    dhcp = FactoryGirl.create(:feature, :dhcp)
    logs = FactoryGirl.create(:feature, :logs)
    assert_equal -1, dhcp <=> logs
  end
end
