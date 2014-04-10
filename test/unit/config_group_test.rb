require 'test_helper'

class ConfigGroupTest < ActiveSupport::TestCase

  test "name can't be blank" do
    refute ConfigGroup.new.valid?
  end

  test "name is unique" do
    refute ConfigGroup.new(:name => 'Monitoring').valid?
  end

end
