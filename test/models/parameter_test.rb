require 'test_helper'

class ParameterTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end
  test "names may be reused in different parameter groups" do
    host = FactoryBot.create(:host)
    p1 = HostParameter.new :name => "param", :value => "value1", :reference_id => host.id
    assert p1.save
    p2 = DomainParameter.new :name => "param", :value => "value2", :reference_id => Domain.first.id
    assert p2.save
    p3 = CommonParameter.new :name => "param", :value => "value3"
    assert p3.save
    p4 = GroupParameter.new :name => "param", :value => "value4", :reference_id => Hostgroup.first.id
    assert p4.save
    p5 = LocationParameter.new :name => "param", :value => "value5", :reference_id => Location.first.id
    assert p5.save
    p6 = OrganizationParameter.new :name => "param", :value => "value6", :reference_id => Organization.first.id
    assert p6.save
    p7 = SubnetParameter.new :name => "param", :value => "value7", :reference_id => Subnet.first.id
    assert p7.save
    p8 = OsParameter.new :name => "param", :value => "value8", :reference_id => Operatingsystem.first.id
    assert p8.save
  end

  test "parameters are hierarchically applied" do
    CommonParameter.create :name => "animal", :value => "cat"

    host         = FactoryBot.create(:host, :with_hostgroup, :with_subnet, :managed)
    organization = host.organization
    location     = host.location
    domain       = host.domain
    hostgroup    = host.hostgroup
    subnet       = host.subnet
    os           = host.operatingsystem

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

    subnet.subnet_parameters << SubnetParameter.create(:name => "animal", :value => "pigeon")
    host.clear_host_parameters_cache!
    assert_equal "pigeon", host.host_params["animal"]

    os.os_parameters << OsParameter.create(:name => "animal", :value => "tortoise")
    host.clear_host_parameters_cache!
    assert_equal "tortoise", host.host_params["animal"]

    hostgroup.group_parameters << GroupParameter.create(:name => "animal",:value => "cow")
    host.clear_host_parameters_cache!
    assert_equal "cow", host.host_params["animal"]

    host.host_parameters << HostParameter.create(:name => "animal", :value => "pig")
    host.clear_host_parameters_cache!
    assert_equal "pig", host.host_params["animal"]
  end

  test "parameters should display correct safe value for nested taxonomies" do
    loc1 = FactoryBot.create(:location)
    loc2 = FactoryBot.create(:location, :parent => loc1)
    host = FactoryBot.create(:host, :location => loc2)

    loc1.location_parameters << LocationParameter.create(:name => "animal", :value => "lion")
    params = host.host_inherited_params(true)
    assert_equal "lion", params["animal"][:safe_value]
    assert_equal loc1.title, params["animal"][:source_name]

    loc2.location_parameters << LocationParameter.create(:name => "animal", :value => "dog")
    params = host.host_inherited_params(true)
    assert_equal "dog", params["animal"][:safe_value]
    assert_equal loc2.title, params["animal"][:source_name]
  end

  test "should allow multi-line value with leading trailing whitespace" do
    val = <<EOF

this is a multiline value
with leading and trailing whitespace

EOF
    param = CommonParameter.new(:name => 'multiline', :value => val)
    assert param.save!
    assert_equal param.value, val
  end
end
