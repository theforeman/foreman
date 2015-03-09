require "test_helper"

class ClassificationTest < ActiveSupport::TestCase

  def setup
    host = FactoryGirl.create(:host,
                              :location => taxonomies(:location1),
                              :organization => taxonomies(:organization1),
                              :operatingsystem => operatingsystems(:redhat),
                              :puppetclasses => [puppetclasses(:one)],
                              :environment => environments(:production))
    @classification = Classification::ClassParam.new(:host => host)
    @global_param_classification = Classification::GlobalParam.new(:host => host)
  end

  test 'it should return puppetclasses' do
    assert classification.send(:puppetclass_ids).map(&:to_i).include?(puppetclasses(:one).id)
  end

  test 'classes should have parameters' do
    assert classification.send(:class_parameters).include?(lookup_keys(:complex))
  end

  test 'enc_should_return_cluster_param' do
    enc = classification.enc
    assert_equal 'secret', enc['base']['cluster']
  end

  test 'enc_should_return_updated_cluster_param' do
    key = lookup_keys(:complex)
    assert_equal 'organization,location', key.path
    host = FactoryGirl.create(:host, :location => taxonomies(:location1), :organization => taxonomies(:organization1))
    assert_equal taxonomies(:location1), host.location
    assert_equal taxonomies(:organization1), host.organization

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)},location=#{taxonomies(:location1)}",
                          :value => 'test',
                          :use_puppet_default => false
    end
    enc = classification.enc

    key.reload
    assert_equal value.value, enc['base']['cluster']
  end

  test "#classes is delegated to the host" do
    pc = FactoryGirl.build(:puppetclass)
    host = FactoryGirl.build(:host)
    host.expects(:classes).returns([pc])
    assert_equal [pc], Classification::ClassParam.new(:host => host).classes
  end

  test "#puppetclass_ids is delegated to the host" do
    pc = FactoryGirl.build(:puppetclass)
    host = FactoryGirl.build(:host)
    host.expects(:puppetclass_ids).returns([pc.id])
    assert_equal [pc.id], Classification::ClassParam.new(:host => host).puppetclass_ids
  end

  test "#enc should return hash of class to nil for classes without parameters" do
    env = FactoryGirl.create(:environment)
    pc = FactoryGirl.create(:puppetclass, :environments => [env])
    assert_equal({pc.name => nil}, get_classparam(env, pc).enc)
  end

  test "#enc should not return class parameters where override is false" do
    env = FactoryGirl.create(:environment)
    pc = FactoryGirl.create(:puppetclass, :with_parameters, :environments => [env])
    refute pc.class_params.first.override
    assert_equal({pc.name => nil}, get_classparam(env, pc).enc)
  end

  test "#enc should return default value of class parameters without lookup_values" do
    env = FactoryGirl.create(:environment)
    pc = FactoryGirl.create(:puppetclass, :environments => [env])
    lkey = FactoryGirl.create(:lookup_key, :as_smart_class_param, :puppetclass => pc, :override => true, :default_value => 'test')
    assert_equal({pc.name => {lkey.key => lkey.default_value}}, get_classparam(env, pc).enc)
  end

  test "#enc should return override value of class parameters" do
    env = FactoryGirl.create(:environment)
    pc = FactoryGirl.create(:puppetclass, :environments => [env])
    lkey = FactoryGirl.create(:lookup_key, :as_smart_class_param, :with_override, :puppetclass => pc)
    classparam = get_classparam(env, pc)
    classparam.expects(:attr_to_value).with('comment').returns('override')
    assert_equal({pc.name => {lkey.key => 'overridden value'}}, classparam.enc)
  end

  test "#values_hash should contain element's name" do
    env = FactoryGirl.create(:environment)
    pc = FactoryGirl.create(:puppetclass, :environments => [env])
    lkey = FactoryGirl.create(:lookup_key, :as_smart_class_param, :with_override, :puppetclass => pc)
    classparam = Classification::ClassParam.new
    classparam.expects(:environment_id).returns(env.id)
    classparam.expects(:puppetclass_ids).returns(Array.wrap(pc).map(&:id))
    classparam.expects(:attr_to_value).with('comment').returns('override')

    assert_equal({lkey.id => {lkey.key => {:value => 'overridden value', :element => 'comment', :element_name => 'override'}}}, classparam.send(:values_hash))
  end

  test "#values_hash should treat yaml and json parameters as string" do
    env = FactoryGirl.create(:environment)
    pc = FactoryGirl.create(:puppetclass, :environments => [env])
    yaml_lkey = FactoryGirl.create(:lookup_key, :as_smart_class_param, :with_override,
                              :puppetclass => pc, :key_type => 'yaml', :default_value => '',
                              :overrides => {"comment=override" => 'a: b'})
    json_lkey = FactoryGirl.create(:lookup_key, :as_smart_class_param, :with_override,
                                   :puppetclass => pc, :key_type => 'json', :default_value => '',
                                   :overrides => {"comment=override" => '{"a": "b"}'})
    classparam = Classification::ClassParam.new

    classparam.expects(:environment_id).returns(env.id)
    classparam.expects(:puppetclass_ids).returns(Array.wrap(pc).map(&:id))
    classparam.expects(:attr_to_value).with('comment').returns('override')
    values_hash = classparam.send(:values_hash)

    assert_includes values_hash[yaml_lkey.id][yaml_lkey.key][:value], 'a: b'
    assert_includes values_hash[json_lkey.id][json_lkey.key][:value], '{"a":"b"}'
  end

  test 'smart class parameter of array with avoid_duplicates should return lookup_value array without duplicates' do

    key = FactoryGirl.create(:lookup_key, :as_smart_class_param,
                             :override => true, :key_type => 'array', :merge_overrides => true,
                             :default_value => [], :path => "organization\nlocation", :avoid_duplicates => true,
                             :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => ['test'],
                          :use_puppet_default => false
    end
    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => ['test'],
                          :use_puppet_default => false
    end
    enc = classification.enc

    key.reload

    assert_equal({key.id => {key.key => {:value => value2.value, :element => ['organization', 'location'],
                                         :element_name => ['Organization 1', 'Location 1']}}},
                 classification.send(:values_hash))
  end

  test 'smart class parameter of array without avoid_duplicates should return lookup_value array with duplicates' do
    key = FactoryGirl.create(:lookup_key, :as_smart_class_param,
                             :override => true, :key_type => 'array', :merge_overrides => true,
                             :default_value => [], :path => "organization\nlocation",
                             :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => ['test'],
                          :use_puppet_default => false
    end
    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => ['test'],
                          :use_puppet_default => false
    end
    enc = classification.enc

    key.reload

    assert_equal({key.id => {key.key => {:value => value2.value + value.value,
                                         :element => ['organization', 'location'],
                                         :element_name => ['Organization 1', 'Location 1']}}},
                 classification.send(:values_hash))
  end

  test 'smart class parameter of hash with merge_overrides should return lookup_value hash with array of elements' do
    key = FactoryGirl.create(:lookup_key, :as_smart_class_param,
                             :override => true, :key_type => 'hash', :merge_overrides => true,
                             :default_value => {}, :path => "organization\nlocation",
                             :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:example => {:a => 'test'}},
                          :use_puppet_default => false
    end
    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => {:b => 'test2'}},
                          :use_puppet_default => false
    end
    enc = classification.enc

    key.reload

    assert_equal({key.id => {key.key => {:value => {:example => {:a => 'test', :b => 'test2'}},
                                         :element => ['location', 'organization'],
                                         :element_name => ['Location 1', 'Organization 1']}}},
                 classification.send(:values_hash))
  end

  test 'smart class parameter of hash with merge_overrides should return lookup_value hash with one element' do
    key = FactoryGirl.create(:lookup_key, :as_smart_class_param,
                             :override => true, :key_type => 'hash', :merge_overrides => true,
                             :default_value => {}, :path => "organization\nos\nlocation",
                             :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => 'test2'},
                          :use_puppet_default => false
    end

    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:example => 'test'},
                          :use_puppet_default => false
    end

    enc = classification.enc

    key.reload

    assert_equal({key.id => {key.key => {:value => value.value, :element => ['location', 'organization'],
                                         :element_name => ['Location 1', 'Organization 1']}}},
                 classification.send(:values_hash))

  end

  test 'smart class parameter of hash with merge_overrides and priority should obey priority' do
    key = FactoryGirl.create(:lookup_key, :as_smart_class_param,
                             :override => true, :key_type => 'hash', :merge_overrides => true,
                             :default_value => {}, :path => "organization\nos\nlocation",
                             :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:a => 'test'},
                          :use_puppet_default => false
    end
    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => {:b => 'test2'}},
                          :use_puppet_default => false
    end

    value3 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "os=#{operatingsystems(:redhat)}",
                          :value => {:example => {:b => 'test3'}},
                          :use_puppet_default => false
    end

    enc = classification.enc

    key.reload

    assert_equal({key.id => {key.key => {:value => {:a => 'test', :example => {:b => 'test2'}},
                                         :element => ['location', 'os', 'organization'],
                                         :element_name => ['Location 1', 'Redhat 6.1', 'Organization 1']}}},
                 classification.send(:values_hash))
  end

  test 'smart class parameter of hash with merge_overrides and priority should return lookup_value hash with array of elements' do
    key = FactoryGirl.create(:lookup_key, :as_smart_class_param,
                             :override => true, :key_type => 'hash', :merge_overrides => true,
                             :default_value => {}, :path => "organization\nos\nlocation",
                             :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:example => {:a => 'test'}},
                          :use_puppet_default => false
    end
    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => {:b => 'test2'}},
                          :use_puppet_default => false
    end

    value3 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "os=#{operatingsystems(:redhat)}",
                          :value => {:example => {:a => 'test3'}},
                          :use_puppet_default => false
    end

    enc = classification.enc

    key.reload

    assert_equal({key.id => {key.key => {:value => {:example => {:a => 'test3', :b => 'test2'}},
                                         :element => ['location', 'os', 'organization'],
                                         :element_name => ['Location 1', 'Redhat 6.1', 'Organization 1']}}},
                 classification.send(:values_hash))
  end

  test 'smart variable of array with avoid_duplicates should return lookup_value array without duplicates' do

    key = FactoryGirl.create(:lookup_key, :key_type => 'array', :merge_overrides => true,
                             :default_value => [], :path => "organization\nlocation", :avoid_duplicates => true,
                             :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => ['test'],
                          :use_puppet_default => false
    end
    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => ['test'],
                          :use_puppet_default => false
    end
    enc = global_param_classification.enc

    key.reload

    assert_equal({key.id => {key.key => {:value => value2.value, :element => ['organization', 'location'],
                                         :element_name => ['Organization 1', 'Location 1']}}},
                 global_param_classification.send(:values_hash))
  end

  test 'smart variable of array without avoid_duplicates should return lookup_value array with duplicates' do
    key = FactoryGirl.create(:lookup_key, :key_type => 'array', :merge_overrides => true,
                             :default_value => [], :path => "organization\nlocation",
                             :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => ['test'],
                          :use_puppet_default => false
    end
    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => ['test'],
                          :use_puppet_default => false
    end
    enc = global_param_classification.enc

    key.reload

    assert_equal({key.id => {key.key => {:value => value2.value + value.value,
                                         :element => ['organization', 'location'],
                                         :element_name => ['Organization 1', 'Location 1']}}},
                 global_param_classification.send(:values_hash))
  end

  test 'smart variable of hash in hash with merge_overrides should return lookup_value hash with array of elements' do
    key = FactoryGirl.create(:lookup_key, :key_type => 'hash', :merge_overrides => true,
                             :default_value => {}, :path => "organization\nlocation",
                             :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:example => {:a => 'test'}},
                          :use_puppet_default => false
    end
    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => {:b => 'test2'}},
                          :use_puppet_default => false
    end
    enc = global_param_classification.enc

    key.reload

    assert_equal({key.id => {key.key => {:value => {:example => {:a => 'test', :b => 'test2'}},
                                         :element => ['location', 'organization'],
                                         :element_name => ['Location 1', 'Organization 1']}}},
                 global_param_classification.send(:values_hash))
  end

  test 'smart variable of hash with merge_overrides and priority should obey priority' do
    key = FactoryGirl.create(:lookup_key, :key_type => 'hash', :merge_overrides => true,
                             :default_value => {}, :path => "organization\nos\nlocation",
                             :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:a => 'test'},
                          :use_puppet_default => false
    end
    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => {:b => 'test2'}},
                          :use_puppet_default => false
    end

    value3 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "os=#{operatingsystems(:redhat)}",
                          :value => {:example => {:b => 'test3'}},
                          :use_puppet_default => false
    end

    enc = global_param_classification.enc

    key.reload

    assert_equal({key.id => {key.key => {:value => {:a => 'test', :example => {:b => 'test2'}},
                                         :element => ['location', 'os', 'organization'],
                                         :element_name => ['Location 1', 'Redhat 6.1', 'Organization 1']}}},
                 global_param_classification.send(:values_hash))
  end

  test 'smart variable of hash with merge_overrides and priority should return lookup_value hash with array of elements' do
    key = FactoryGirl.create(:lookup_key, :key_type => 'hash', :merge_overrides => true,
                             :default_value => {}, :path => "organization\nos\nlocation",
                             :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:example => {:a => 'test'}},
                          :use_puppet_default => false
    end
    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => {:b => 'test2'}},
                          :use_puppet_default => false
    end

    value3 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "os=#{operatingsystems(:redhat)}",
                          :value => {:example => {:a => 'test3'}},
                          :use_puppet_default => false
    end

    enc = global_param_classification.enc

    key.reload

    assert_equal({key.id => {key.key => {:value => {:example => {:a => 'test3', :b => 'test2'}},
                                         :element => ['location', 'os', 'organization'],
                                         :element_name => ['Location 1', 'Redhat 6.1', 'Organization 1']}}},
                 global_param_classification.send(:values_hash))
  end

  test "#enc should not return class parameters when default value should use puppet default" do
    lkey = FactoryGirl.create(:lookup_key, :as_smart_class_param, :with_override, :with_use_puppet_default,
                              :puppetclass => puppetclasses(:one))
    enc = classification.enc
    assert enc['base'][lkey.key].nil?
  end

  test "#enc should not return class parameters when lookup_value should use puppet default" do
    lkey = FactoryGirl.create(:lookup_key, :as_smart_class_param, :with_override, :with_use_puppet_default,
                              :puppetclass => puppetclasses(:one), :path => "location")
    as_admin do
      LookupValue.create! :lookup_key_id => lkey.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => 'test',
                          :use_puppet_default => true
    end

    enc = classification.enc
    assert enc['base'][lkey.key].nil?
  end

  test "#enc should return class parameters when default value and lookup_values should not use puppet default" do
    lkey = FactoryGirl.create(:lookup_key, :as_smart_class_param, :with_override, :use_puppet_default => false,
                              :puppetclass => puppetclasses(:one), :path => "location")
    lvalue = as_admin do
      LookupValue.create! :lookup_key_id => lkey.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => 'test',
                          :use_puppet_default => false
    end
    enc = classification.enc
    assert_equal lvalue.value, enc['base'][lkey.key]
  end

  test "#enc should not return class parameters when merged lookup_values and default are all using puppet default" do
    key = FactoryGirl.create(:lookup_key, :as_smart_class_param, :use_puppet_default => true,
                             :override => true, :key_type => 'hash', :merge_overrides => true,
                             :default_value => {}, :path => "organization\nos\nlocation",
                             :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:example => {:a => 'test'}},
                          :use_puppet_default => true
    end
    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => {:b => 'test2'}},
                          :use_puppet_default => true
    end

    value3 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "os=#{operatingsystems(:redhat)}",
                          :value => {:example => {:a => 'test3'}},
                          :use_puppet_default => true
    end

    enc = classification.enc
    assert enc['base'][key.key].nil?
  end

  test "#enc should return correct override to host when multiple overrides for inherited hostgroups exist" do
    FactoryGirl.create(:setting,
                       :name => 'host_group_matchers_inheritance',
                       :value => true)
    key = FactoryGirl.create(:lookup_key, :as_smart_class_param, :use_puppet_default => true,
                             :override => true, :key_type => 'string', :merge_overrides => false,
                             :path => "organization\nhostgroup\nlocation",
                             :puppetclass => puppetclasses(:two))

    parent_hostgroup = FactoryGirl.create(:hostgroup,
                                          :puppetclasses => [puppetclasses(:two)],
                                          :environment => environments(:production))
    child_hostgroup = FactoryGirl.create(:hostgroup, :parent => parent_hostgroup)

    host = @classification.send(:host)
    host.hostgroup = child_hostgroup
    host.save

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "hostgroup=#{parent_hostgroup}",
                          :value => "parent",
                          :use_puppet_default => false
    end
    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "hostgroup=#{child_hostgroup}",
                          :value => "child",
                          :use_puppet_default => false
    end

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match =>"organization=#{taxonomies(:organization1)}",
                          :value => "org",
                          :use_puppet_default => false
    end

    enc = classification.enc

    assert_equal 'org', enc["apache"][key.key]
  end

  test "#enc should return correct override to host when multiple overrides for inherited hostgroups exist" do
    FactoryGirl.create(:setting,
                       :name => 'host_group_matchers_inheritance',
                       :value => true)
    key = FactoryGirl.create(:lookup_key, :as_smart_class_param, :use_puppet_default => true,
                             :override => true, :key_type => 'string', :merge_overrides => false,
                             :path => "organization\nhostgroup\nlocation",
                             :puppetclass => puppetclasses(:two))

    parent_hostgroup = FactoryGirl.create(:hostgroup,
                                          :puppetclasses => [puppetclasses(:two)],
                                          :environment => environments(:production))
    child_hostgroup = FactoryGirl.create(:hostgroup, :parent => parent_hostgroup)

    host = @classification.send(:host)
    host.hostgroup = child_hostgroup
    host.save

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "hostgroup=#{parent_hostgroup}",
                          :value => "parent",
                          :use_puppet_default => false
    end
    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "hostgroup=#{child_hostgroup}",
                          :value => "child",
                          :use_puppet_default => false
    end

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match =>"location=#{taxonomies(:location1)}",
                          :value => "loc",
                          :use_puppet_default => true
    end

    enc = classification.enc

    assert_equal 'child', enc["apache"][key.key]
  end

  test 'smart class parameter should accept string with erb for arrays and evaluate it properly' do
    key = FactoryGirl.create(:lookup_key, :as_smart_class_param,
                             :override => true, :key_type => 'array', :merge_overrides => false,
                             :default_value => '<%= [1,2] %>', :path => "organization\nos\nlocation",
                             :puppetclass => puppetclasses(:one))
    assert_equal [1,2], classification.enc['base'][key.key]

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => '<%= [2,3] %>',
                          :use_puppet_default => false
    end
    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => '<%= [3,4] %>',
                          :use_puppet_default => false
    end
    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "os=#{operatingsystems(:redhat)}",
                          :value => '<%= [4,5] %>',
                          :use_puppet_default => false
    end

    key.reload
    @classification = Classification::ClassParam.new(:host => classification.send(:host))

    assert_equal({key.id => {key.key => {:value => '<%= [3,4] %>',
                                         :element => 'organization',
                                         :element_name => 'Organization 1'}}},
                 classification.send(:values_hash))
    assert_equal [3,4], classification.enc['base'][key.key]
  end

  test 'smart class parameter with erb values is validated after erb is evaluated' do
    key = FactoryGirl.create(:lookup_key, :as_smart_class_param,
                             :override => true, :key_type => 'string', :merge_overrides => false,
                             :default_value => '<%= "a" %>', :path => "organization\nos\nlocation",
                             :puppetclass => puppetclasses(:one),
                             :validator_type => 'list', :validator_rule => 'b')

    assert_raise RuntimeError do
      classification.enc['base'][key.key]
    end

    key.update_attribute :default_value, '<%= "b" %>'
    @classification = Classification::ClassParam.new(:host => classification.send(:host))
    assert_equal 'b', classification.enc['base'][key.key]

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => '<%= "c" %>',
                          :use_puppet_default => false
    end

    key.reload
    @classification = Classification::ClassParam.new(:host => classification.send(:host))

    assert_raise RuntimeError do
      classification.enc['base'][key.key]
    end
  end

  context 'lookup value type cast error' do
    setup do
      @lookup_key = mock('lookup_key')
      @lookup_key.expects(:cast_validate_value).raises(TypeError)
      @lookup_key.expects(:key_type).returns('footype')
    end

    test 'TypeError exceptions are logged' do
      Rails.logger.expects(:warn).with('Unable to type cast bar to footype')
      @classification.send(:type_cast, @lookup_key, 'bar')
    end
  end

  private

  attr_reader :classification
  attr_reader :global_param_classification

  def get_classparam(env, classes)
    classification = Classification::ClassParam.new
    classification.expects(:classes).returns(Array.wrap(classes))
    classification.expects(:environment_id).returns(env.id)
    classification.expects(:puppetclass_ids).returns(Array.wrap(classes).map(&:id))
    classification
  end

end
