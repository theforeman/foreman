require 'test_helper'
require 'models/shared/taxonomies_base_test'

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
      RFauxFactory.gen_html(rand((1..217))),
    ]
  end

  # List of invalid organization names.
  def invalid_org_name_list
    [
      '',
      ' ',
      "\t",
    ]
  end

  test "create with multi names" do
    valid_org_name_list.each do |name|
      organization = FactoryBot.build(:organization, :name => name)
      assert organization.valid?, "Validation failed for create with valid name: '#{name}' length: #{name.length})"
      assert_equal organization.name, name
    end
  end

  test "should not create with invalid names" do
    invalid_org_name_list.each do |name|
      organization = FactoryBot.build(:organization, :name => name)
      refute organization.valid?, "Validation succeeded for create with invalid name: '#{name}' length: #{name.length})"
      assert_includes organization.errors.keys, :name
    end
  end

  test "update with multi names" do
    organization = FactoryBot.create(:organization)
    valid_org_name_list.each do |new_name|
      organization.name = new_name
      assert organization.valid?, "Validation failed for update with valid name: '#{new_name}' length: #{new_name.length})"
      assert_equal organization.name, new_name
    end
  end

  test "should not update with invalid name" do
    organization = Organization.first
    invalid_org_name_list.each do |name|
      organization.name = name
      refute organization.valid?, "Validation succeeded for update with invalid name: '#{name}' length: #{name.length})"
      assert_includes organization.errors.keys, :name
    end
  end
end
