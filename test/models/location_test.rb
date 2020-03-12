require 'test_helper'
require 'models/shared/taxonomies_base_test'

class LocationTest < ActiveSupport::TestCase
  include TaxonomiesBaseTest
  # List of valid location names.
  def valid_loc_name_list
    [
      RFauxFactory.gen_alpha(1),
      RFauxFactory.gen_alpha(246),
      *RFauxFactory.gen_strings(1..246, exclude: [:html]).values,
      RFauxFactory.gen_html(rand((1..221))),
    ]
  end

  # List of invalid location names.
  def invalid_loc_name_list
    [
      '',
      ' ',
      "\t",
    ]
  end

  test 'should create with multiple valid names' do
    valid_loc_name_list.each do |name|
      location = FactoryBot.build(:location, :name => name)
      assert location.valid?, "Can't create location with valid name #{name}"
    end
  end

  test 'should not create with multiple invalid names' do
    invalid_loc_name_list.each do |name|
      location = FactoryBot.build(:location, :name => name)
      refute location.valid?, "Can create location with invalid name #{name}"
      assert_includes location.errors.keys, :name
    end
  end

  test 'should update with multiple valid names' do
    location = FactoryBot.create(:location)
    valid_loc_name_list.each do |name|
      location.name = name
      assert location.valid?, "Can't update location with valid name #{name}"
    end
  end

  test 'should update with multiple valid descriptions' do
    location = FactoryBot.create(:location)
    RFauxFactory.gen_strings(300).values.each do |description|
      location.description = description
      assert location.valid?, "Can't update location with valid description #{description}"
    end
  end

  test 'should not update with multiple invalid names' do
    location = FactoryBot.create(:location)
    invalid_loc_name_list.each do |name|
      location.name = name
      refute location.valid?, "Can update location with invalid name #{name}"
      assert_includes location.errors.keys, :name
    end
  end
end
