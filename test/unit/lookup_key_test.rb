require 'test_helper'

class LookupKeyTest < ActiveSupport::TestCase

  def test_element_seperations
    key = ""
    as_admin do
      key = LookupKey.create!(:key => "ntp", :path => "domain,system_group\n domain", :puppetclass => Puppetclass.first)
    end
    elements = key.send(:path_elements) # hack to access private method
    assert_equal "domain", elements[0][0]
    assert_equal "system_group", elements[0][1]
    assert_equal "domain", elements[1][0]
  end

  def test_path2match_single_domain_path
    key   = ""
    value = ""
    as_admin do
      key   = LookupKey.create!(:key => "ntp", :path => "domain", :puppetclass => Puppetclass.first)
      value = LookupValue.create!(:value => "ntp.mydomain.net", :match => "domain =  mydomain.net", :lookup_key => key)
    end

    system = systems(:one)
    system.domain = domains(:mydomain)
    assert_equal [value.match], key.send(:path2matches,system)
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
    system = systems(:one)
    system.domain = domains(:mydomain)

    assert_equal value.value, Classification::ClassParam.new(:system=>system).enc['base']['dns']
  end

  def test_path2match_single_system_group_path
    key   = ""
    value = ""
    as_admin do
      key   = LookupKey.create!(:key => "ntp", :path => "system_group", :puppetclass => Puppetclass.first)
      value = LookupValue.create!(:value => "ntp.pool.org", :match => "system_group =  Common", :lookup_key => key)
    end
    system = systems(:one)
    system.system_group = system_groups(:common)
    assert_equal [value.match], key.send(:path2matches,system)
  end

  def test_multiple_paths
    system = systems(:one)
    system.system_group = system_groups(:common)
    system.environment = environments(:testing)

    system2 = systems(:minimal)
    system2.system_group = system_groups(:unusual)
    system2.environment = environments(:testing)

    system3 = systems(:redhat)
    system3.environment = environments(:testing)

    default = "default"
    key    = ""
    value1 = ""
    value2 = ""
    puppetclass = Puppetclass.first
    as_admin do
      key    = LookupKey.create!(:key => "dns", :path => "environment,system_group \n system_group", :puppetclass => puppetclass, :default_value => default, :override=>true)
      value1 = LookupValue.create!(:value => "v1", :match => "environment=testing,system_group=Common", :lookup_key => key)
      value2 = LookupValue.create!(:value => "v2", :match => "system_group=Unusual", :lookup_key => key)
      EnvironmentClass.create!(:puppetclass => puppetclass, :environment => environments(:testing), :lookup_key => key)
      SystemClass.create!(:system => system,:puppetclass=>puppetclass)
      SystemClass.create!(:system => system2,:puppetclass=>puppetclass)
      SystemClass.create!(:system => system3,:puppetclass=>puppetclass)
    end

    key.reload

    assert_equal value1.value, Classification::ClassParam.new(:system=>system).enc['apache']['dns']
    assert_equal value2.value, Classification::ClassParam.new(:system=>system2).enc['apache']['dns']
    assert_equal default, Classification::ClassParam.new(:system=>system3).enc['apache']['dns']
  end

  def test_parameters_multiple_paths
     system = systems(:one)
     system.system_group = system_groups(:common)
     system.environment = environments(:testing)

     system2 = systems(:minimal)
     system2.system_group = system_groups(:unusual)

     system3 = systems(:redhat)

     default = "default"
     key    = ""
     value1 = ""
     value2 = ""
     puppetclass = Puppetclass.first
     as_admin do
       key    = LookupKey.create!(:key => "dns", :path => "environment,system_group \n system_group", :puppetclass => puppetclass, :default_value => default, :override=>true)
       value1 = LookupValue.create!(:value => "v1", :match => "environment=testing,system_group=Common", :lookup_key => key)
       value2 = LookupValue.create!(:value => "v2", :match => "system_group=Unusual", :lookup_key => key)
       system.puppetclasses << puppetclass
       system2.puppetclasses << puppetclass
       system3.puppetclasses << puppetclass
     end

     key.reload

     assert_equal value1.value, Classification::GlobalParam.new(:system=>system).enc['dns']
     assert_equal value2.value, Classification::GlobalParam.new(:system=>system2).enc['dns']
     assert_equal default, Classification::GlobalParam.new(:system=>system3).enc['dns']
   end

  def test_value_should_not_be_changed
    param = lookup_keys(:three)
    default = param.default_value
    param.save
    assert_equal default, param.default_value
    assert_equal default, param.default_value_before_type_cast
  end

  test "this is a smart variable?" do
    assert lookup_keys(:two).is_smart_variable?
  end

  test "this is a smart class parameter?" do
    assert lookup_keys(:complex).is_smart_class_parameter?
  end

end
