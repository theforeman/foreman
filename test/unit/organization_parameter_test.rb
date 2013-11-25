require 'test_helper'

class OrganizationParameterTest < ActiveSupport::TestCase

  setup do
    User.current = users :admin
  end

  test 'should have a reference_id' do
    organization_parameter       = OrganizationParameter.new
    organization_parameter.name  = 'valid'
    organization_parameter.value = 'valid'
    assert_not organization_parameter.save

    organization                        = Organization.first
    organization_parameter.reference_id = organization.id
    assert organization_parameter.save
  end

  test 'duplicate names cannot exist for a organization' do
    organization = taxonomies(:organization1)
    parameter1 = OrganizationParameter.create! :name => 'some_parameter', :value => 'value', :reference_id => organization.id
    parameter2 = OrganizationParameter.create :name => 'some_parameter', :value => 'value', :reference_id => organization.id
    assert_not parameter2.valid?
    assert_equal ['has already been taken'], parameter2.errors[:name]
  end

  test 'duplicate names can exist for different taxonomies' do
    organization1 = taxonomies(:organization1)
    organization2 = taxonomies(:organization2)
    assert OrganizationParameter.create! :name => 'some_parameter', :value => 'value', :reference_id => organization1.id
    assert OrganizationParameter.create! :name => 'some_parameter', :value => 'value', :reference_id => organization2.id
  end

end
