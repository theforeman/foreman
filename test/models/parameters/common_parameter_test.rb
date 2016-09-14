require 'test_helper'

class CommonParameterTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should_not validate_presence_of(:value)
  should validate_uniqueness_of(:name)
end
