require 'test_helper'
require 'models/shared/taxonomies_base_test'
require 'rfauxfactory'

class OrganizationTest < ActiveSupport::TestCase
  include TaxonomiesBaseTest

  # List of valid organization names.
  def valid_org_name_list
    # Note: The maximum allowed length of org name is 242 only. This is an
    # intended behavior (Also note that 255 is the standard across other
    # entities.)
    [
      RFauxFactory.gen_alpha(1),
      RFauxFactory.gen_alpha(242),
      *RFauxFactory.gen_strings(1..242, exclude: [:html]).values,
      RFauxFactory.gen_html(rand((1..217)))
    ]
  end

  # List of invalid organization names.
  def invalid_org_name_list
    [
      '',
      ' ',
      "\t",
      *RFauxFactory.gen_strings(243).values
    ]
  end

  test "create with multi names" do
    valid_org_name_list.each do |name|
      organization = FactoryBot.create(:organization, :name => name)
      organization.reload
      assert_equal organization.name, name
    end
  end

  test "should not create with invalid names" do
    invalid_org_name_list.each do |name|
      organization = Organization.new(:name => name)
      refute organization.valid?
      assert_includes organization.errors.keys, :name
    end
  end

  test "create with multi name and description" do
    valid_org_name_list.each do |name|
      organization = FactoryBot.create(:organization, :name => name, :description => name)
      organization.reload
      assert_equal organization.name, name
      assert_equal organization.description, name
    end
  end

  test "should not update with invalid name" do
    organization = Organization.first
    invalid_org_name_list.each do |name|
      organization.name = name
      refute organization.valid?
      assert_includes organization.errors.keys, :name
    end
  end
end
