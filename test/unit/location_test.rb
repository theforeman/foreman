require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  def setup
    User.current = users(:admin)
  end

  def setup_user operation
    super operation, "location"
  end

  test 'it should not save without an empty name' do
    location = Location.new
    assert !location.save
  end

  test 'it should not save with a blank name' do
    location = Location.new
    location.name = "      "
    assert !location.save
  end

  test 'it should not save another location with the same name' do
    location = Location.new
    location.name = "location1"
    assert location.save

    second_location = Location.new
    second_location.name = "location1"
    assert !second_location.save
  end

  test 'it should show the name for to_s' do
    location = Location.new :name => "location name"
    assert location.to_s == location.name
  end
end
