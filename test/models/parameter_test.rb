require 'test_helper'

class ParameterTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end
  test "names may be reused in different parameter groups" do
    host = FactoryGirl.create(:host)
    p1 = LookupValue.new :key => "param", :value => "value1", :match => host.lookup_value_matcher
    assert p1.save
    p2 = LookupValue.new :key => "param", :value => "value1", :match => "domain=#{Domain.first.title}"
    assert p2.save
    p3 =  GlobalLookupKey.where(:key => "param").first
    p3.default_value = "value3"
    p3.should_be_global = true
    assert p3.save
    p4 =  LookupValue.new :key => "param", :value => "value1", :match => "hostgroup=#{Hostgroup.first.title}"
    assert p4.save
    p5 = LookupValue.new :key => "param", :value => "value1", :match => "location={Location.first.title}"
    assert p5.save
    p6 =  LookupValue.new :key => "param", :value => "value1", :match => "organization=#{Organization.first.title}"
    assert p6.save
    p7 = LookupValue.new :key => "param", :value => "value7", :match => "subnet=#{Subnet.first.name}"
    assert p7.save
    p8 = LookupValue.new :key => "param", :value => "value8", :match => "os=#{Operatingsystem.first}"
    assert p8.save
  end

  test "parameters are hierarchically applied" do
    GlobalLookupKey.create :key => "animal", :default_value => "cat", :should_be_global => true

    host         = FactoryGirl.create(:host, :with_hostgroup, :with_subnet, :managed)
    organization = host.organization
    location     = host.location
    domain       = host.domain
    hostgroup    = host.hostgroup
    subnet       = host.subnet
    os           = host.operatingsystem

    GlobalLookupKey.create :key => "animal", :default_value => "cat", :should_be_global => true
    assert_equal "cat", host.host_params["animal"]

    LookupValue.create(:key => "animal", :value => "tiger", :match => "organization=#{organization.title}")
    host.clear_host_parameters_cache!
    assert_equal "tiger", host.host_params["animal"]

    LookupValue.create(:key => "animal", :value => "lion", :match => "location=#{location.title}")
    host.clear_host_parameters_cache!
    assert_equal "lion", host.host_params["animal"]

    LookupValue.create(:key => "animal", :value => "dog", :match => "domain=#{domain.title}")
    host.clear_host_parameters_cache!
    assert_equal "dog", host.host_params["animal"]

    LookupValue.create(:key => "animal", :value => "pigeon", :match => "subnet=#{subnet.to_s}")
    host.clear_host_parameters_cache!
    assert_equal "pigeon", host.host_params["animal"]

    LookupValue.create(:key => "animal", :value => "bear", :match => "os=#{os.title}")
    host.clear_host_parameters_cache!
    assert_equal "bear", host.host_params["animal"]

    LookupValue.create(:key => "animal", :value => "cow", :match => "hostgroup=#{hostgroup.title}")
    host.clear_host_parameters_cache!
    assert_equal "cow", host.host_params["animal"]

    LookupValue.create(:key => "animal", :value => "pig", :match => "fqdn=#{host.fqdn}")
    host.clear_host_parameters_cache!
    assert_equal "pig", host.host_params["animal"]
  end

  test "parameters should display correct safe value for nested taxonomies" do
    FactoryGirl.create(:setting,
                       :name => 'host_group_matchers_inheritance',
                       :value => true)
    loc1 = FactoryGirl.create(:location)
    loc2 = FactoryGirl.create(:location, :parent => loc1)
    host = FactoryGirl.create(:host, :location => loc2)

    GlobalLookupKey.create :key => "animal", :default_value => "cat", :should_be_global => true
    lv1 = LookupValue.create(:key => "animal", :value => "lion", :match => "location=#{loc1.title}")
    host.clear_host_parameters_cache!
    params = host.host_params
    assert_equal lv1.safe_value, params["animal"]

    lv2 = LookupValue.create(:key => "animal", :value => "dog", :match => "location=#{loc2.title}")
    host.clear_host_parameters_cache!
    params = host.host_params
    assert_equal lv2.safe_value, params["animal"]
  end

  test "should allow multi-line value with leading trailing whitespace" do
    val = <<EOF

this is a multiline value
with leading and trailing whitespace

EOF
    param = GlobalLookupKey.new(:key => 'multiline', :default_value => val, :should_be_global => true)
    assert param.save!
    assert_equal param.value, val
  end
end
