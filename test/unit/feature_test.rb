require 'test_helper'

class FeatureTest < ActiveSupport::TestCase
  should have_and_belong_to_many(:smart_proxies)
  should validate_presence_of(:name)
end
