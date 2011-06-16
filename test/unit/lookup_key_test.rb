require 'test_helper'

class LookupKeyTest < ActiveSupport::TestCase

  def test_element_seperations
    key = LookupKey.create(:key => "ntp", :path => "domain,hostgroup\n domain")
    elements = key.send(:path_elements) # hack to access private method
    assert_equal "domain", elements[0][0]
    assert_equal "hostgroup", elements[0][1]
    assert_equal "domain", elements[1][0]
  end

  def test_path2match_single_domain_path
    key = LookupKey.create(:key => "ntp", :path => "domain", :puppetclass => Puppetclass.first)
    value = LookupValue.create(:value => "ntp.mydomain.net", :match => "domain =  mydomain.net", :lookup_key => key)

    host = hosts(:one)
    host.domain = domains(:mydomain)
    assert_equal [value.match], key.send(:path2matches,host)
  end

  def test_fetching_the_correct_value_to_a_given_key
    key = LookupKey.create(:key => "dns", :path => "domain\npuppetversion", :puppetclass => Puppetclass.first)
    value = LookupValue.create(:value => "[1.2.3.4,2.3.4.5]", :match => "domain =  mydomain.net", :lookup_key => key)

    host = hosts(:one)
    host.domain = domains(:mydomain)
    assert_equal value.value, key.value_for(host)
  end

  def test_path2match_single_hostgroup_path
    key = LookupKey.create(:key => "ntp", :path => "hostgroup", :puppetclass => Puppetclass.first)
    value = LookupValue.create(:value => "ntp.pool.org", :match => "hostgroup =  Common", :lookup_key => key)
    host = hosts(:one)
    host.hostgroup = hostgroups(:common)
    assert_equal [value.match], key.send(:path2matches,hosts(:one))
  end

  def test_multiple_paths
    host = hosts(:one)
    host.hostgroup = hostgroups(:common)
    host.environment = environments(:testing)

    host2 = hosts(:minimal)
    host2.hostgroup = hostgroups(:unusual)

    default = "default"
    key = LookupKey.create(:key => "dns", :path => "environment, hostgroup \n hostgroup", :puppetclass => Puppetclass.first, :default_value => default)
    value1 = LookupValue.create(:value => "v1", :match => "environment = testing, hostgroup = Common", :lookup_key => key)
    value2 = LookupValue.create(:value => "v2", :match => "hostgroup = Unusual", :lookup_key => key)

    assert_equal LookupValue.find(value1).value, key.value_for(host)
    assert_equal LookupValue.find(value2).value, key.value_for(host2)
    assert_equal default, key.value_for(hosts(:redhat))
  end
end
