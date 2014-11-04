require 'test_helper'

class ParameterTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end
  test  "names may be reused in different parameter groups" do
    host = FactoryGirl.create(:host)
    p1 = HostParameter.new   :name => "param", :value => "value1", :reference_id => host.id
    assert p1.save
    p2 = DomainParameter.new :name => "param", :value => "value2", :reference_id => Domain.first.id
    assert p2.save
    p3 = CommonParameter.new :name => "param", :value => "value3"
    assert p3.save
    p4 = GroupParameter.new  :name => "param", :value => "value4", :reference_id => Hostgroup.first.id
    assert p4.save
    p5 = LocationParameter.new  :name => "param", :value => "value5", :reference_id => Location.first.id
    assert p5.save
    p6 = OrganizationParameter.new  :name => "param", :value => "value6", :reference_id => Organization.first.id
    assert p6.save
  end

  test "parameters are hierarchically applied" do
    CommonParameter.create :name => "animal", :value => "cat"

    host         = FactoryGirl.create(:host, :with_hostgroup, :managed)
    organization = host.organization
    location     = host.location
    domain       = host.domain
    hostgroup    = host.hostgroup

    CommonParameter.create :name => "animal", :value => "cat"
    assert_equal "cat", host.host_params["animal"]

    organization.organization_parameters << OrganizationParameter.create(:name => "animal", :value => "tiger")
    host.clear_host_parameters_cache!
    assert_equal "tiger", host.host_params["animal"]

    location.location_parameters << LocationParameter.create(:name => "animal", :value => "lion")
    host.clear_host_parameters_cache!
    assert_equal "lion", host.host_params["animal"]

    domain.domain_parameters << DomainParameter.create(:name => "animal", :value => "dog")
    host.clear_host_parameters_cache!
    assert_equal "dog", host.host_params["animal"]

    hostgroup.group_parameters << GroupParameter.create(:name => "animal",:value => "cow")
    host.clear_host_parameters_cache!
    assert_equal "cow", host.host_params["animal"]

    host.host_parameters << HostParameter.create(:name => "animal", :value => "pig")
    host.clear_host_parameters_cache!
    assert_equal "pig", host.host_params["animal"]
  end
end
