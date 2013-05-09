require 'test_helper'

class LookupKeyTest < ActiveSupport::TestCase

  def test_element_seperations
    key = ""
    as_admin do
      key = LookupKey.create!(:key => "ntp", :path => "domain,hostgroup\n domain", :puppetclass => Puppetclass.first)
    end
    elements = key.send(:path_elements) # hack to access private method
    assert_equal "domain", elements[0][0]
    assert_equal "hostgroup", elements[0][1]
    assert_equal "domain", elements[1][0]
  end

  def test_path2match_single_domain_path
    key   = ""
    value = ""
    as_admin do
      key   = LookupKey.create!(:key => "ntp", :path => "domain", :puppetclass => Puppetclass.first)
      value = LookupValue.create!(:value => "ntp.mydomain.net", :match => "domain =  mydomain.net", :lookup_key => key)
    end

    host = hosts(:one)
    host.domain = domains(:mydomain)
    assert_equal [value.match], key.send(:path2matches,host)
  end

  def test_fetching_the_correct_value_to_a_given_key
    key   = ""
    value = ""
    puppetclass = puppetclasses(:one)

    as_admin do
      key   = LookupKey.create!(:key => "dns", :path => "domain\npuppetversion", :puppetclass => puppetclass,:override=>true)
      value = LookupValue.create!(:value => "[1.2.3.4,2.3.4.5]", :match => "domain =  mydomain.net", :lookup_key => key)
      EnvironmentClass.create!(:puppetclass => puppetclass, :environment => environments(:production), :lookup_key => key)
    end

    key.reload
    assert key.lookup_values_count > 0
    host = hosts(:one)
    host.domain = domains(:mydomain)

    assert_equal value.value, Classification.new(:host=>host).enc['base']['dns']
  end

  def test_path2match_single_hostgroup_path
    key   = ""
    value = ""
    as_admin do
      key   = LookupKey.create!(:key => "ntp", :path => "hostgroup", :puppetclass => Puppetclass.first)
      value = LookupValue.create!(:value => "ntp.pool.org", :match => "hostgroup =  Common", :lookup_key => key)
    end
    host = hosts(:one)
    host.hostgroup = hostgroups(:common)
    assert_equal [value.match], key.send(:path2matches,host)
  end

  def test_multiple_paths
    host = hosts(:one)
    host.hostgroup = hostgroups(:common)
    host.environment = environments(:testing)

    host2 = hosts(:minimal)
    host2.hostgroup = hostgroups(:unusual)
    host2.environment = environments(:testing)

    host3 = hosts(:redhat)
    host3.environment = environments(:testing)

    default = "default"
    key    = ""
    value1 = ""
    value2 = ""
    puppetclass = Puppetclass.first
    as_admin do
      key    = LookupKey.create!(:key => "dns", :path => "environment,hostgroup \n hostgroup", :puppetclass => puppetclass, :default_value => default, :override=>true)
      value1 = LookupValue.create!(:value => "v1", :match => "environment=testing,hostgroup=Common", :lookup_key => key)
      value2 = LookupValue.create!(:value => "v2", :match => "hostgroup=Unusual", :lookup_key => key)
      EnvironmentClass.create!(:puppetclass => puppetclass, :environment => environments(:testing), :lookup_key => key)
      HostClass.create!(:host => host,:puppetclass=>puppetclass)
      HostClass.create!(:host => host2,:puppetclass=>puppetclass)
      HostClass.create!(:host => host3,:puppetclass=>puppetclass)
    end

    key.reload

    assert_equal value1.value, Classification.new(:host=>host).enc['apache']['dns']
    assert_equal value2.value, Classification.new(:host=>host2).enc['apache']['dns']
    assert_equal default, Classification.new(:host=>host3).enc['apache']['dns']
  end

  def test_value_should_not_be_changed
    param = lookup_keys(:three)
    default = param.default_value
    param.save
    assert_equal default, param.default_value
    assert_equal default, param.default_value_before_type_cast
  end
end
