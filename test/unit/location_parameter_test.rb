require 'test_helper'

class LocationParameterTest < ActiveSupport::TestCase

  setup do
    User.current = users :admin
  end

  test 'should have a reference_id' do
    location_parameter       = LocationParameter.new
    location_parameter.name  = 'valid'
    location_parameter.value = 'valid'
    assert_not location_parameter.save

    location                        = Location.first
    location_parameter.reference_id = location.id
    assert location_parameter.save
  end

  test 'duplicate names cannot exist for a location' do
    location = taxonomies(:location1)
    parameter1 = LocationParameter.create! :name => 'some_parameter', :value => 'value', :reference_id => location.id
    parameter2 = LocationParameter.create :name => 'some_parameter', :value => 'value', :reference_id => location.id
    assert_not parameter2.valid?
    assert_equal ['has already been taken'], parameter2.errors[:name]
  end

  test 'duplicate names can exist for different taxonomies' do
    location1 = taxonomies(:location1)
    location2 = taxonomies(:location2)
    assert LocationParameter.create! :name => 'some_parameter', :value => 'value', :reference_id => location1.id
    assert LocationParameter.create! :name => 'some_parameter', :value => 'value', :reference_id => location2.id
  end

end
