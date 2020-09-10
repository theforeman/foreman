require 'test_helper'

class FeatureTest < ActiveSupport::TestCase
  should have_many(:smart_proxies)
  should have_many(:smart_proxy_features)
  should validate_presence_of(:name)
end
