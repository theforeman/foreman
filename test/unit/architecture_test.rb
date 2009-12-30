require 'test_helper'

class ArchitectureTest < ActiveSupport::TestCase
  test "should not save without a name" do
    a = Architecture.new
    assert !a.save
  end

  test "name should not contain white spaces" do
    a = Architecture.new :name => "  "
    assert !a.save
  end
end
