require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  test 'it should not save with an empty name' do
    organization = Organization.new
    assert !organization.save
  end

  test 'it should not save with a blank name' do
    organization = Organization.new
    organization.name = " "
    assert !organization.save
  end

  test 'it should not save another organization with the same name' do
    organization = Organization.new
    tenant.name = "organization1"
    assert organization.save

    second_organization = Organization.new
    second_organization.name = "organization1"
    assert !second_organization.save
  end

  test 'it should show the name for to_s' do
    organization = Organization.new :name => "organization1"
    assert organization.to_s == "organization1"
  end
end
