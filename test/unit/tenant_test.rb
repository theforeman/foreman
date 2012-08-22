require 'test_helper'

class TenantTest < ActiveSupport::TestCase
  test 'it should not save without an empty name' do
    tenant = Tenant.new
    assert !tenant.save
  end

  test 'it should not save with a blank name' do
    tenant = Tenant.new
    tenant.name = " "
    assert !tenant.save
  end

  test 'it should not save another tenant with the same name' do
    tenant = Tenant.new
    tenant.name = "tenant1"
    assert tenant.save

    second_tenant = Tenant.new
    second_tenant.name = "tenant1"
    assert !second_tenant.save
  end

  test 'it should show the name for to_s' do
    tenant = Tenant.new :name => "tenant1"
    assert tenant.to_s == "tenant1"
  end
end
