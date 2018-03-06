require 'test_helper'
require 'models/shared/taxonomies_base_test'
require 'rfauxfactory'

class LocationTest < ActiveSupport::TestCase
  include TaxonomiesBaseTest
  valid_loc_data_list = [
    RFauxFactory.gen_alpha(1),
    RFauxFactory.gen_alpha(246),
    *RFauxFactory.gen_strings(1..246, exclude: [:html]).values,
    RFauxFactory.gen_html(rand((1..221)))
  ]
  invalid_loc_name_list = [
    '',
    ' ',
    "\t",
    *RFauxFactory.gen_strings(247).values
  ]

  test 'should create with multiple valid names' do
    valid_loc_data_list.each do |name|
      location = FactoryBot.create(:location, :name => name)
      location.reload
      assert_equal name, location.name
    end
  end

  test 'should not create with multiple invalid names' do
    invalid_loc_name_list.each do |name|
      location = Location.new(:name => name)
      refute location.valid?
    end
  end

  test 'should update with multiple valid names' do
    location = FactoryBot.create(:location, :name => name)
    valid_loc_data_list.each do |name|
      location.name = name
      location.save
      updated_location = Location.find_by_id(location.id)
      assert_equal name, updated_location.name
    end
  end

  test 'should update with multiple valid descriptions' do
    location = FactoryBot.create(:location)
    valid_loc_data_list.each do |description|
      location.description = description
      location.save
      updated_location = Location.find_by_id(location.id)
      assert_equal description, updated_location.description
    end
  end

  test 'should not update with multiple invalid names' do
    location = FactoryBot.create(:location)
    invalid_loc_name_list.each do |name|
      location.name = name
      refute location.valid?
    end
  end
end
