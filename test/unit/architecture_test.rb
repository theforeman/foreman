require 'test_helper'

class ArchitectureTest < ActiveSupport::TestCase
  test "should not save without a name" do
    architecture = Architecture.new
    assert !architecture.save
  end

  test "name should not contain white spaces" do
    architecture = Architecture.new :name => "  "
    assert !architecture.save
  end
end
