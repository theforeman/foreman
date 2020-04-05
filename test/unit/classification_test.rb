require "test_helper"

class ClassificationTest < ActiveSupport::TestCase
  def setup
    @host = FactoryBot.build(:host,
      :location => taxonomies(:location1),
      :organization => taxonomies(:organization1),
      :operatingsystem => operatingsystems(:redhat),
      :puppetclasses => [puppetclasses(:one)],
      :environment => environments(:production))
  end

  test 'enc_should_return_cluster_param' do
    enc = HostInfoProviders::PuppetInfo.new(@host).puppetclass_parameters
    assert_equal 'secret', enc['base']['cluster']
  end

  test 'enc_should_return_updated_cluster_param' do
    key = lookup_keys(:complex)
    assert_equal "fqdn\norganization,location\nhostgroup\nos", key.path
    assert_equal taxonomies(:location1), @host.location
    assert_equal taxonomies(:organization1), @host.organization

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)},location=#{taxonomies(:location1)}",
                          :value => 'test',
                          :omit => false
    end
    enc = HostInfoProviders::PuppetInfo.new(@host).puppetclass_parameters

    key.reload
    assert_equal value.value, enc['base']['cluster']
  end

  test "#enc should return hash of class to nil for classes without parameters" do
    env = FactoryBot.build(:environment)
    pc = FactoryBot.build(:puppetclass, :environments => [env])
    assert_equal({pc.name => nil}, get_classparam(env, pc).puppetclass_parameters)
  end

  test "#enc should not return class parameters where override is false" do
    env = FactoryBot.create(:environment)
    pc = FactoryBot.create(:puppetclass, :with_parameters, :environments => [env])
    refute pc.class_params.first.override
    assert_equal({pc.name => nil}, get_classparam(env, pc).puppetclass_parameters)
  end

  test "#enc should return default value of class parameters without lookup_values" do
    env = FactoryBot.create(:environment)
    pc = FactoryBot.create(:puppetclass, :environments => [env])
    lkey = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :puppetclass => pc, :override => true, :default_value => 'test')
    assert_equal({pc.name => {lkey.key => lkey.default_value}}, get_classparam(env, pc).puppetclass_parameters)
  end

  test "#enc should return override value of class parameters" do
    env = FactoryBot.create(:environment)
    pc = FactoryBot.create(:puppetclass, :environments => [env])
    lkey = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override, :puppetclass => pc)
    classparam = get_classparam(env, pc)
    host = classparam.send(:host)
    host.expects(:comment).returns('override')
    assert_equal({pc.name => {lkey.key => 'overridden value'}}, classparam.puppetclass_parameters)
  end

  test "#values_hash should contain element's name" do
    env = FactoryBot.create(:environment)
    pc = FactoryBot.create(:puppetclass, :environments => [env])
    lkey = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override, :puppetclass => pc)
    host = FactoryBot.build_stubbed(:host, :environment => env, :puppetclasses => [pc])
    Classification::MatchesGenerator.any_instance.expects(:attr_to_value).with('comment').returns('override')

    assert_equal(
      {
        lkey.id => {
          lkey.key => {
            :value => 'overridden value',
            :element => 'comment',
            :element_name => 'override',
            :managed => false,
          },
        },
      },
      Classification::ValuesHashQuery.values_hash(host, LookupKey.where(:id => [lkey])).raw
    )

    Classification::MatchesGenerator.any_instance.unstub(:attr_to_value)
  end

  test "#values_hash should treat yaml and json parameters as string" do
    env = FactoryBot.build(:environment)
    pc = FactoryBot.build(:puppetclass, :environments => [env])
    yaml_lkey = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override,
      :puppetclass => pc, :key_type => 'yaml', :default_value => '',
      :overrides => {"comment=override" => 'a: b'})
    json_lkey = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override,
      :puppetclass => pc, :key_type => 'json', :default_value => '',
      :overrides => {"comment=override" => '{"a": "b"}'})

    host = FactoryBot.build_stubbed(:host, :environment => env, :puppetclasses => [pc])

    Classification::MatchesGenerator.any_instance.expects(:attr_to_value).twice.with('comment').returns('override')
    values_hash = Classification::ValuesHashQuery.values_hash(host, LookupKey.where(:id => [json_lkey, yaml_lkey]))

    assert_includes values_hash.raw[yaml_lkey.id][yaml_lkey.key][:value], 'a: b'
    assert_includes values_hash.raw[json_lkey.id][json_lkey.key][:value], '{"a":"b"}'
    Classification::MatchesGenerator.any_instance.unstub(:attr_to_value)
  end

  test "ClassificationResult should correctly typecast JSON and YAML default values" do
    env = FactoryBot.build(:environment)
    pc = FactoryBot.build(:puppetclass, :environments => [env])
    yaml_lkey = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :override => true,
                                   :puppetclass => pc, :key_type => 'yaml', :default_value => 'a: b')
    json_lkey = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :override => true,
                                   :puppetclass => pc, :key_type => 'json', :default_value => '{"a": "b"}')
    host = FactoryBot.build_stubbed(:host, :environment => env, :puppetclasses => [pc])
    classparam = Classification::ClassificationResult.new(host, {})

    yaml_value = classparam[yaml_lkey]
    json_value = classparam[json_lkey]

    assert_equal yaml_value, {'a' => 'b'}
    assert_equal json_value, {'a' => 'b'}
  end

  test 'smart class parameter of array with avoid_duplicates should return lookup_value array without duplicates' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'array', :merge_overrides => true,
      :default_value => [], :path => "organization\nlocation", :avoid_duplicates => true,
      :puppetclass => puppetclasses(:one))

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => ['test'],
                          :omit => false
    end
    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => ['test'],
                          :omit => false
    end
    key.reload

    assert_equal({key.id => {key.key => {:value => value2.value, :element => ['organization', 'location'],
                                         :element_name => ['Organization 1', 'Location 1']}}},
      Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
  end

  test 'smart class parameter of array without avoid_duplicates should return lookup_value array with duplicates' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'array', :merge_overrides => true,
      :default_value => [], :path => "organization\nlocation",
      :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => ['test'],
                          :omit => false
    end
    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => ['test'],
                          :omit => false
    end
    key.reload

    assert_equal({key.id => {key.key => {:value => value2.value + value.value,
                                         :element => ['organization', 'location'],
                                         :element_name => ['Organization 1', 'Location 1']}}},
      Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
  end

  test 'smart class parameter of hash with merge_overrides should return lookup_value hash with array of elements' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'hash', :merge_overrides => true,
      :default_value => {}, :path => "organization\nlocation",
      :puppetclass => puppetclasses(:one))

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:example => {:a => 'test'}},
                          :omit => false
    end
    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => {:b => 'test2'}},
                          :omit => false
    end
    key.reload

    assert_equal({key.id => {key.key => {:value => {:example => {:a => 'test', :b => 'test2'}},
                                         :element => ['location', 'organization'],
                                         :element_name => ['Location 1', 'Organization 1']}}},
      Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
  end

  test 'smart class parameter of hash with merge_overrides should return lookup_value hash with one element' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'hash', :merge_overrides => true,
      :default_value => {}, :path => "organization\nos\nlocation",
      :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => 'test2'},
                          :omit => false
    end
    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:example => 'test'},
                          :omit => false
    end
    key.reload

    assert_equal({key.id => {key.key => {:value => value.value, :element => ['location', 'organization'],
                                         :element_name => ['Location 1', 'Organization 1']}}},
      Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
  end

  test 'smart class parameter of hash with merge_overrides and priority should obey priority' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'hash', :merge_overrides => true,
      :default_value => {}, :path => "organization\nos\nlocation",
      :puppetclass => puppetclasses(:one))

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:a => 'test'},
                          :omit => false
    end
    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => {:b => 'test2'}},
                          :omit => false
    end

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "os=#{operatingsystems(:redhat)}",
                          :value => {:example => {:b => 'test3'}},
                          :omit => false
    end
    key.reload

    assert_equal({key.id => {key.key => {:value => {:a => 'test', :example => {:b => 'test2'}},
                                         :element => ['location', 'os', 'organization'],
                                         :element_name => ['Location 1', 'Redhat 6.1', 'Organization 1']}}},
      Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
  end

  test 'smart class parameter of hash with merge_overrides and priority should return lookup_value hash with array of elements' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'hash', :merge_overrides => true,
      :default_value => {}, :path => "organization\nos\nlocation",
      :puppetclass => puppetclasses(:one))

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:example => {:a => 'test'}},
                          :omit => false
    end
    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => {:b => 'test2'}},
                          :omit => false
    end
    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "os=#{operatingsystems(:redhat)}",
                          :value => {:example => {:a => 'test3'}},
                          :omit => false
    end
    key.reload

    assert_equal({key.id => {key.key => {:value => {:example => {:a => 'test3', :b => 'test2'}},
                                         :element => ['location', 'os', 'organization'],
                                         :element_name => ['Location 1', 'Redhat 6.1', 'Organization 1']}}},
      Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
  end

  test 'smart class parameter with omit on specific matcher does not send a value to puppet' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'string',
      :default_value => "123", :path => "organization\nos\nlocation",
      :puppetclass => puppetclasses(:one))

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => "345",
                          :omit => true
    end

    enc = HostInfoProviders::PuppetInfo.new(@host).puppetclass_parameters
    refute enc['base'].key?(key.key)
  end

  test 'smart class parameter of array with avoid_duplicates should return lookup_value array without duplicates' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :key_type => 'array', :merge_overrides => true,
                             :default_value => [], :path => "organization\nlocation", :avoid_duplicates => true,
                             :puppetclass => puppetclasses(:one))

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => ['test']
    end
    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => ['test']
    end
    key.reload

    assert_equal({key.id => {key.key => {:value => value2.value, :element => ['organization', 'location'],
                                         :element_name => ['Organization 1', 'Location 1']}}},
      Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
  end

  test 'smart class parameter of array without avoid_duplicates should return lookup_value array with duplicates' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :key_type => 'array',
                             :merge_overrides => true, :default_value => [], :path => "organization\nlocation",
                             :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => ['test']
    end
    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => ['test']
    end
    key.reload

    assert_equal({key.id => {key.key => {:value => value2.value + value.value,
                                         :element => ['organization', 'location'],
                                         :element_name => ['Organization 1', 'Location 1']}}},
      Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
  end

  test 'smart class parameter of hash in hash with merge_overrides should return lookup_value hash with array of elements' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :key_type => 'hash',
                             :merge_overrides => true, :default_value => {}, :path => "organization\nlocation",
                             :puppetclass => puppetclasses(:one))

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:example => {:a => 'test'}}
    end
    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => {:b => 'test2'}}
    end
    key.reload

    assert_equal({key.id => {key.key => {:value => {:example => {:a => 'test', :b => 'test2'}},
                                         :element => ['location', 'organization'],
                                         :element_name => ['Location 1', 'Organization 1']}}},
      Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
  end

  test 'smart class parameter of hash with merge_overrides and priority should obey priority' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :key_type => 'hash',
                             :merge_overrides => true, :default_value => {}, :path => "organization\nos\nlocation",
                             :puppetclass => puppetclasses(:one))

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:a => 'test'}
    end
    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => {:b => 'test2'}}
    end

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "os=#{operatingsystems(:redhat)}",
                          :value => {:example => {:b => 'test3'}}
    end
    key.reload

    assert_equal({key.id => {key.key => {:value => {:a => 'test', :example => {:b => 'test2'}},
                                         :element => ['location', 'os', 'organization'],
                                         :element_name => ['Location 1', 'Redhat 6.1', 'Organization 1']}}},
      Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
  end

  test 'smart class parameter of hash with merge_overrides and priority should return lookup_value hash with array of elements' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :key_type => 'hash',
                             :merge_overrides => true, :default_value => {}, :path => "organization\nos\nlocation",
                             :puppetclass => puppetclasses(:one))

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:example => {:a => 'test'}}
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => {:b => 'test2'}}
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "os=#{operatingsystems(:redhat)}",
                          :value => {:example => {:a => 'test3'}}
    end
    key.reload

    assert_equal({key.id => {key.key => {:value => {:example => {:a => 'test3', :b => 'test2'}},
                                         :element => ['location', 'os', 'organization'],
                                         :element_name => ['Location 1', 'Redhat 6.1', 'Organization 1']}}},
      Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
  end

  test 'smart class parameter of hash without merge_default should not merge with default value' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :key_type => 'hash',
                             :merge_overrides => true, :default_value => {:default => 'example'},
                             :path => "organization\nos\nlocation", :puppetclass => puppetclasses(:one))

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:a => 'test2'}
    end
    key.reload

    assert_equal({key.id => {key.key => {:value => {:a => 'test2' },
                                         :element => ['organization'],
                                         :element_name => ['Organization 1']}}},
      Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
  end

  test 'smart class parameter of hash with merge_overrides and merge_default should return merge all values' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'hash', :merge_overrides => true, :merge_default => true,
      :default_value => { :default => 'default' }, :path => "organization\nlocation",
      :puppetclass => puppetclasses(:one))

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:example => {:a => 'test'}},
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => {:b => 'test2'}},
                          :omit => false
    end
    key.reload

    assert_equal({key.id => {key.key => {:value => {:default => 'default', :example => {:a => 'test', :b => 'test2'}},
                                         :element => ['Default value', 'location', 'organization'],
                                         :element_name => ['Default value', 'Location 1', 'Organization 1']}}},
      Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
  end

  test "#enc should not return class parameters when default value should use puppet default" do
    lkey = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override, :with_omit,
      :puppetclass => puppetclasses(:one))

    enc = HostInfoProviders::PuppetInfo.new(@host).puppetclass_parameters
    assert enc['base'][lkey.key].nil?
  end

  test "#enc should not return class parameters when lookup_value should use puppet default" do
    lkey = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override, :with_omit,
      :puppetclass => puppetclasses(:one), :path => "location\ncomment")
    as_admin do
      LookupValue.create! :lookup_key_id => lkey.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => 'test',
                          :omit => true
    end

    enc = HostInfoProviders::PuppetInfo.new(@host).puppetclass_parameters

    assert enc['base'][lkey.key].nil?
  end

  test "#enc should return class parameters when default value and lookup_values should not use puppet default" do
    lkey = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_override, :omit => false,
                              :puppetclass => puppetclasses(:one), :path => "location\ncomment")
    lvalue = as_admin do
      LookupValue.create! :lookup_key_id => lkey.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => 'test',
                          :omit => false
    end

    enc = HostInfoProviders::PuppetInfo.new(@host).puppetclass_parameters

    assert_equal lvalue.value, enc['base'][lkey.key]
  end

  test "#enc should not return class parameters when merged lookup_values and default are all using puppet default" do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :omit => true,
                             :override => true, :key_type => 'hash', :merge_overrides => true,
                             :default_value => {}, :path => "organization\nos\nlocation",
                             :puppetclass => puppetclasses(:one))

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => {:example => {:a => 'test'}},
                          :omit => true
    end
    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => {:example => {:b => 'test2'}},
                          :omit => true
    end

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "os=#{operatingsystems(:redhat)}",
                          :value => {:example => {:a => 'test3'}},
                          :omit => true
    end

    enc = HostInfoProviders::PuppetInfo.new(@host).puppetclass_parameters

    assert enc['base'][key.key].nil?
  end

  test "#enc should return correct merged override to host when multiple overrides for inherited hostgroups exist" do
    FactoryBot.create(:setting,
      :name => 'matchers_inheritance',
      :value => true)
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :omit => true,
                             :override => true, :key_type => 'array', :merge_overrides => true,
                             :path => "organization\nhostgroup\nlocation",
                             :puppetclass => puppetclasses(:two))

    parent_hostgroup = FactoryBot.create(:hostgroup,
      :puppetclasses => [puppetclasses(:two)],
      :environment => environments(:production))
    child_hostgroup = FactoryBot.build(:hostgroup, :parent => parent_hostgroup)

    host = FactoryBot.create(:host, :environment => environments(:production), :organization => taxonomies(:organization1),
      :puppetclasses => [puppetclasses(:one)], :hostgroup => child_hostgroup)

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "hostgroup=#{parent_hostgroup}",
                          :value => ['parent'],
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => ['org'],
                          :omit => false
    end

    enc = HostInfoProviders::PuppetInfo.new(host).puppetclass_parameters

    assert_equal ['org', 'parent'], enc["apache"][key.key]
  end

  test "#enc should return correct merged override to host when multiple overrides for inherited organizations exist" do
    FactoryBot.create(:setting,
      :name => 'matchers_inheritance',
      :value => true)
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :omit => true,
                             :override => true, :key_type => 'array', :merge_overrides => true,
                             :path => "location\norganization\nhostgroup",
                             :puppetclass => puppetclasses(:two))

    parent_org = taxonomies(:organization1)
    child_org = taxonomies(:organization2)
    child_org.update(:parent => parent_org)

    host = FactoryBot.create(:host, :environment => environments(:production), :puppetclasses => [puppetclasses(:two)], :organization => child_org, :location => taxonomies(:location1))

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{parent_org}",
                          :value => ['parent'],
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => ['loc'],
                          :omit => false
    end

    enc = HostInfoProviders::PuppetInfo.new(host).puppetclass_parameters

    assert_equal ['loc', 'parent'], enc["apache"][key.key]
  end

  test "#enc should return correct merged override to host when multiple overrides for inherited locations exist" do
    FactoryBot.create(:setting,
      :name => 'matchers_inheritance',
      :value => true)
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :omit => true,
                             :override => true, :key_type => 'array', :merge_overrides => true,
                             :path => "organization\nhostgroup\nlocation",
                             :puppetclass => puppetclasses(:two))

    parent_loc = taxonomies(:location1)
    child_loc = taxonomies(:location2)
    child_loc.update(:parent => parent_loc)

    host = FactoryBot.create(:host, :environment => environments(:production), :puppetclasses => [puppetclasses(:two)], :organization => taxonomies(:organization1), :location => child_loc)

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{parent_loc}",
                          :value => ['parent'],
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => ['org'],
                          :omit => false
    end

    enc = HostInfoProviders::PuppetInfo.new(host).puppetclass_parameters

    assert_equal ['org', 'parent'], enc["apache"][key.key]
  end

  test "#enc should return correct merged override to host when multiple overrides for inherited hostgroups exist" do
    FactoryBot.create(:setting,
      :name => 'matchers_inheritance',
      :value => true)
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :omit => true,
                             :override => true, :key_type => 'array', :merge_overrides => true,
                             :path => "organization\nhostgroup\nlocation",
                             :puppetclass => puppetclasses(:two))

    parent_hostgroup = FactoryBot.create(:hostgroup,
      :puppetclasses => [puppetclasses(:two)],
      :environment => environments(:production))
    child_hostgroup = FactoryBot.build(:hostgroup, :parent => parent_hostgroup)

    host = FactoryBot.create(:host, :environment => environments(:production), :organization => taxonomies(:organization1),
      :puppetclasses => [puppetclasses(:one)], :hostgroup => child_hostgroup)

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "hostgroup=#{parent_hostgroup}",
                          :value => ['parent'],
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "hostgroup=#{child_hostgroup}",
                          :value => ['child'],
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => ['org'],
                          :omit => false
    end

    enc = HostInfoProviders::PuppetInfo.new(host).puppetclass_parameters

    assert_equal ['org', 'child', 'parent'], enc["apache"][key.key]
  end

  test "#enc should return correct merged override to host when multiple overrides for inherited organizations exist" do
    FactoryBot.create(:setting,
      :name => 'matchers_inheritance',
      :value => true)
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :omit => true,
                             :override => true, :key_type => 'array', :merge_overrides => true,
                             :path => "location\norganization\nhostgroup",
                             :puppetclass => puppetclasses(:two))

    parent_org = taxonomies(:organization1)
    child_org = taxonomies(:organization2)
    child_org.update(:parent => parent_org)

    host = FactoryBot.create(:host, :environment => environments(:production), :puppetclasses => [puppetclasses(:two)], :organization => child_org, :location => taxonomies(:location1))

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{parent_org}",
                          :value => ['parent'],
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{child_org}",
                          :value => ['child'],
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => ['loc'],
                          :omit => false
    end

    enc = HostInfoProviders::PuppetInfo.new(host).puppetclass_parameters

    assert_equal ['loc', 'child', 'parent'], enc["apache"][key.key]
  end

  test "#enc should return correct merged override to host when multiple overrides for inherited locations exist" do
    FactoryBot.create(:setting,
      :name => 'matchers_inheritance',
      :value => true)
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :omit => true,
                             :override => true, :key_type => 'array', :merge_overrides => true,
                             :path => "organization\nhostgroup\nlocation",
                             :puppetclass => puppetclasses(:two))

    parent_loc = taxonomies(:location1)
    child_loc = taxonomies(:location2)
    child_loc.update(:parent => parent_loc)

    host = FactoryBot.create(:host, :environment => environments(:production), :puppetclasses => [puppetclasses(:two)], :organization => taxonomies(:organization1), :location => child_loc)

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{parent_loc}",
                          :value => ['parent'],
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{child_loc}",
                          :value => ['child'],
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => ['org'],
                          :omit => false
    end

    enc = HostInfoProviders::PuppetInfo.new(host).puppetclass_parameters

    assert_equal ['org', 'child', 'parent'], enc["apache"][key.key]
  end

  test "#enc should return correct override to host when multiple overrides for inherited hostgroups exist" do
    FactoryBot.create(:setting,
      :name => 'matchers_inheritance',
      :value => true)
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :omit => true,
                             :override => true, :key_type => 'string', :merge_overrides => false,
                             :path => "organization\nhostgroup\nlocation",
                             :puppetclass => puppetclasses(:two))

    parent_hostgroup = FactoryBot.create(:hostgroup,
      :puppetclasses => [puppetclasses(:two)],
      :environment => environments(:production))
    child_hostgroup = FactoryBot.build(:hostgroup, :parent => parent_hostgroup)

    host = FactoryBot.create(:host, :environment => environments(:production), :organization => taxonomies(:organization1),
      :puppetclasses => [puppetclasses(:one)], :hostgroup => child_hostgroup)

    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "hostgroup=#{parent_hostgroup}",
                          :value => "parent",
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "hostgroup=#{child_hostgroup}",
                          :value => "child",
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => "org",
                          :omit => false
    end

    enc = HostInfoProviders::PuppetInfo.new(host).puppetclass_parameters

    assert_equal value2.value, enc["apache"][key.key]
  end

  test "#enc should return correct override to host when multiple overrides for inherited organizations exist" do
    FactoryBot.create(:setting,
      :name => 'matchers_inheritance',
      :value => true)
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :omit => true,
                             :override => true, :key_type => 'string', :merge_overrides => false,
                             :path => "location\norganization\nhostgroup",
                             :puppetclass => puppetclasses(:two))

    parent_org = taxonomies(:organization1)
    child_org = taxonomies(:organization2)
    child_org.update(:parent => parent_org)

    host = FactoryBot.create(:host, :environment => environments(:production), :organization => child_org,
      :puppetclasses => [puppetclasses(:two)], :location => taxonomies(:location1))

    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{parent_org}",
                          :value => "parent",
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{child_org}",
                          :value => "child",
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => "loc",
                          :omit => false
    end

    enc = HostInfoProviders::PuppetInfo.new(host).puppetclass_parameters

    assert_equal value2.value, enc["apache"][key.key]
  end

  test "#enc should return correct override to host when multiple overrides for inherited locations exist" do
    FactoryBot.create(:setting,
      :name => 'matchers_inheritance',
      :value => true)
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :omit => true,
                             :override => true, :key_type => 'string', :merge_overrides => false,
                             :path => "organization\nlocation\nhostgroup",
                             :puppetclass => puppetclasses(:two))

    parent_loc = taxonomies(:location1)
    child_loc = taxonomies(:location2)
    child_loc.update(:parent => parent_loc)

    host = FactoryBot.create(:host, :environment => environments(:production), :organization => taxonomies(:organization1),
      :puppetclasses => [puppetclasses(:two)], :location => child_loc)

    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{parent_loc}",
                          :value => "parent",
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{child_loc}",
                          :value => "child",
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => "org",
                          :omit => false
    end

    enc = HostInfoProviders::PuppetInfo.new(host).puppetclass_parameters

    assert_equal value2.value, enc["apache"][key.key]
  end

  test "#enc should return correct override to host when multiple overrides for inherited hostgroups exist" do
    FactoryBot.create(:setting,
      :name => 'matchers_inheritance',
      :value => true)
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :omit => true,
                             :override => true, :key_type => 'string', :merge_overrides => false,
                             :path => "organization\nhostgroup\nlocation",
                             :puppetclass => puppetclasses(:two))

    parent_hostgroup = FactoryBot.create(:hostgroup,
      :puppetclasses => [puppetclasses(:two)],
      :environment => environments(:production))
    child_hostgroup = FactoryBot.build(:hostgroup, :parent => parent_hostgroup)

    host = FactoryBot.create(:host, :environment => environments(:production), :puppetclasses => [puppetclasses(:one)], :hostgroup => child_hostgroup)

    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "hostgroup=#{parent_hostgroup}",
                          :value => "parent",
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => "loc",
                          :omit => true
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "hostgroup=#{child_hostgroup}",
                          :value => "child",
                          :omit => false
    end

    enc = HostInfoProviders::PuppetInfo.new(host).puppetclass_parameters

    assert_equal value2.value, enc["apache"][key.key]
  end

  test "#enc should return correct override to host when multiple overrides for inherited organizations exist" do
    FactoryBot.create(:setting,
      :name => 'matchers_inheritance',
      :value => true)
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :omit => true,
                             :override => true, :key_type => 'string', :merge_overrides => false,
                             :path => "organization\nhostgroup\nlocation",
                             :puppetclass => puppetclasses(:two))

    parent_org = taxonomies(:organization1)
    child_org = taxonomies(:organization2)
    child_org.update(:parent => parent_org)

    host = FactoryBot.create(:host, :environment => environments(:production), :puppetclasses => [puppetclasses(:two)], :organization => child_org, :location => taxonomies(:location1))

    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{parent_org}",
                          :value => "parent",
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => "loc",
                          :omit => true
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{child_org}",
                          :value => "child",
                          :omit => false
    end

    enc = HostInfoProviders::PuppetInfo.new(host).puppetclass_parameters

    assert_equal value2.value, enc["apache"][key.key]
  end

  test "#enc should return correct override to host when multiple overrides for inherited locations exist" do
    FactoryBot.create(:setting,
      :name => 'matchers_inheritance',
      :value => true)
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :omit => true,
                             :override => true, :key_type => 'string', :merge_overrides => false,
                             :path => "location\norganization\nhostgroup",
                             :puppetclass => puppetclasses(:two))

    parent_loc = taxonomies(:location1)
    child_loc = taxonomies(:location2)
    child_loc.update(:parent => parent_loc)

    host = FactoryBot.create(:host, :environment => environments(:production), :puppetclasses => [puppetclasses(:two)], :organization => taxonomies(:organization1), :location => child_loc)

    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{parent_loc}",
                          :value => "parent",
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => "org",
                          :omit => true
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{child_loc}",
                          :value => "child",
                          :omit => false
    end

    enc = HostInfoProviders::PuppetInfo.new(host).puppetclass_parameters

    assert_equal value2.value, enc["apache"][key.key]
  end

  test 'enc should return correct values for multi-key matchers' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'string', :default_value => '',
      :path => "organization\norganization,location\nlocation",
      :puppetclass => puppetclasses(:one))

    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => 'test_incorrect',
                          :omit => false
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)},location=#{taxonomies(:location1)}",
                          :value => 'test_correct',
                          :omit => false
    end
    enc = HostInfoProviders::PuppetInfo.new(@host).puppetclass_parameters
    key.reload

    assert_equal value2.value, enc["base"][key.key]
  end

  test 'enc should return correct values for multi-key matchers with more specific first' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'string', :default_value => '',
      :path => "organization,location\norganization",
      :puppetclass => puppetclasses(:one))

    value = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)},location=#{taxonomies(:location1)}",
                          :value => 'test_correct',
                          :omit => false
    end
    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => 'test_incorrect',
                          :omit => false
    end
    enc = HostInfoProviders::PuppetInfo.new(@host).puppetclass_parameters

    assert_equal value.value, enc["base"][key.key]
  end

  test 'enc should return correct values for multi-key matchers with hostgroup inheritance' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :omit => true,
                             :override => true, :key_type => 'string', :merge_overrides => false,
                             :path => "hostgroup,organization\nlocation",
                             :puppetclass => puppetclasses(:two))

    parent_hostgroup = FactoryBot.create(:hostgroup,
      :puppetclasses => [puppetclasses(:two)],
      :environment => environments(:production))
    child_hostgroup = FactoryBot.build(:hostgroup, :parent => parent_hostgroup)

    host = FactoryBot.create(:host, :environment => environments(:production),
      :location => taxonomies(:location1), :organization => taxonomies(:organization1),
      :puppetclasses => [puppetclasses(:one)], :hostgroup => child_hostgroup)

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "hostgroup=#{parent_hostgroup},organization=#{taxonomies(:organization1)}",
                          :value => "parent",
                          :omit => false
    end
    value2 = as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "hostgroup=#{child_hostgroup},organization=#{taxonomies(:organization1)}",
                          :value => "child",
                          :omit => false
    end

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => "loc",
                          :omit => false
    end

    enc = HostInfoProviders::PuppetInfo.new(host).puppetclass_parameters
    key.reload
    assert_equal value2.value, enc["apache"][key.key]
  end

  test 'smart class parameter should accept string with erb for arrays and evaluate it properly' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'array', :merge_overrides => false,
      :default_value => '<%= [1,2] %>', :path => "organization\nos\nlocation",
      :puppetclass => puppetclasses(:one))
    assert_equal [1, 2], HostInfoProviders::PuppetInfo.new(@host).puppetclass_parameters['base'][key.key]

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => '<%= [2,3] %>',
                          :omit => false
    end
    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)}",
                          :value => '<%= [3,4] %>',
                          :omit => false
    end
    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "os=#{operatingsystems(:redhat)}",
                          :value => '<%= [4,5] %>',
                          :omit => false
    end

    key.reload

    assert_equal({key.id => {key.key => {:value => '<%= [3,4] %>',
                                         :element => 'organization',
                                         :element_name => 'Organization 1',
                                         :managed => false}}},
      Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
    assert_equal [3, 4], HostInfoProviders::PuppetInfo.new(@host).puppetclass_parameters['base'][key.key]
  end

  test 'enc should return correct values for multi-key matchers' do
    hostgroup = FactoryBot.build(:hostgroup)

    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :with_omit,
      :override => true, :key_type => 'string', :merge_overrides => false,
      :path => "hostgroup,organization\nlocation",
      :puppetclass => puppetclasses(:two))

    parent_hostgroup = FactoryBot.create(:hostgroup,
      :puppetclasses => [puppetclasses(:two)],
      :environment => environments(:production))
    hostgroup.update(:parent => parent_hostgroup)

    FactoryBot.build(:lookup_value, :lookup_key_id => key.id, :match => "hostgroup=#{parent_hostgroup},organization=#{taxonomies(:organization1)}")
    lv = FactoryBot.create(:lookup_value, :lookup_key_id => key.id, :match => "hostgroup=#{hostgroup},organization=#{taxonomies(:organization1)}")
    FactoryBot.build(:lookup_value, :lookup_key_id => key.id, :match => "location=#{taxonomies(:location1)}")

    host = FactoryBot.build_stubbed(:host, :environment => environments(:production),
      :location => taxonomies(:location1), :organization => taxonomies(:organization1), :hostgroup => hostgroup)

    enc = HostInfoProviders::PuppetInfo.new(host).puppetclass_parameters
    key.reload
    assert_equal lv.value, enc["apache"][key.key]
  end

  test 'smart class parameter with erb values is validated after erb is evaluated' do
    key = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param,
      :override => true, :key_type => 'string', :merge_overrides => false,
      :default_value => '<%= "a" %>', :path => "organization\nos\nlocation",
      :puppetclass => puppetclasses(:one),
      :validator_type => 'list', :validator_rule => 'b')

    assert_raise RuntimeError do
      HostInfoProviders::PuppetInfo.new(@host).puppetclass_parameters['base'][key.key]
    end

    key.update_attribute :default_value, '<%= "b" %>'
    assert_equal 'b', HostInfoProviders::PuppetInfo.new(@host).puppetclass_parameters['base'][key.key]

    as_admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "location=#{taxonomies(:location1)}",
                          :value => '<%= "c" %>',
                          :omit => false
    end

    key.reload

    assert_raise RuntimeError do
      HostInfoProviders::PuppetInfo.new(@host).puppetclass_parameters['base'][key.key]
    end
  end

  test 'type cast allows nil values' do
    key = FactoryBot.create(:lookup_key)
    assert_nothing_raised do
      Classification::ClassificationResult.new(nil, {}).send(:type_cast, key, nil)
    end
  end

  context 'lookup value type cast error' do
    setup do
      @lookup_key = mock('lookup_key')
      Foreman::Parameters::Caster.any_instance.expects(:cast).raises(TypeError)
      @lookup_key.expects(:key_type).twice.returns('footype')
    end

    test 'TypeError exceptions are logged' do
      Rails.logger.expects(:warn).with('Unable to type cast bar to footype')
      Classification::ClassificationResult.new(nil, {}).send(:type_cast, @lookup_key, 'bar')
    end
  end

  private

  def get_classparam(env, classes)
    host = Host.new
    host.expects(:classes).returns(Array.wrap(classes))
    host.expects(:environment_id).returns(env.id)
    host.expects(:puppetclass_ids).returns(Array.wrap(classes).map(&:id))
    HostInfoProviders::PuppetInfo.new(host)
  end
end
