require 'test_helper'

class ConfigGroupClassTest < ActiveSupport::TestCase
  should validate_presence_of(:config_group)
  should validate_presence_of(:puppetclass)
  should validate_uniqueness_of(:config_group).scoped_to(:puppetclass_id)
end
