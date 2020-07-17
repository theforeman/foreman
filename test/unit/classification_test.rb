require "test_helper"

class ClassificationTest < ActiveSupport::TestCase
  let(:hash_lookup_merge) {}

  def setup
    @host = FactoryBot.build(:host,
      :location => taxonomies(:location1),
      :organization => taxonomies(:organization1),
      :operatingsystem => operatingsystems(:redhat))
  end

  test "#values_hash should contain element's name" do
    lkey = FactoryBot.create(:lookup_key, :with_override, :overrides => {"comment=override" => 'overridden value'})

    host = FactoryBot.build_stubbed(:host, comment: 'override')

    assert_equal(
      {
        lkey.id => {
          lkey.key => {
            :value => 'overridden value',
            :element => 'comment',
            :element_name => 'override',
          },
        },
      },
      Classification::ValuesHashQuery.values_hash(host, LookupKey.where(:id => [lkey])).raw
    )
  end

  test "#values_hash should treat yaml and json parameters as string" do
    yaml_lkey = FactoryBot.create(:lookup_key, :with_override, :key_type => 'yaml', :default_value => '',
      :overrides => {"comment=override" => 'a: b'})
    json_lkey = FactoryBot.create(:lookup_key, :with_override, :key_type => 'json', :default_value => '',
      :overrides => {"comment=override" => '{"a": "b"}'})

    host = FactoryBot.build_stubbed(:host, comment: 'override')

    values_hash = Classification::ValuesHashQuery.values_hash(host, LookupKey.where(:id => [json_lkey, yaml_lkey]))

    assert_includes values_hash.raw[yaml_lkey.id][yaml_lkey.key][:value], 'a: b'
    assert_includes values_hash.raw[json_lkey.id][json_lkey.key][:value], '{"a":"b"}'
  end

  test "ClassificationResult should correctly typecast JSON and YAML default values" do
    yaml_lkey = FactoryBot.create(:lookup_key, :key_type => 'yaml', :override => true, :default_value => 'a: b')
    json_lkey = FactoryBot.create(:lookup_key, :key_type => 'json', :override => true, :default_value => '{"a": "b"}')
    host = FactoryBot.build_stubbed(:host)
    classparam = Classification::ClassificationResult.new(host, {})

    yaml_value = classparam[yaml_lkey]
    json_value = classparam[json_lkey]

    assert_equal yaml_value, {'a' => 'b'}
    assert_equal json_value, {'a' => 'b'}
  end

  context 'array lookup with merge_overrides' do
    context 'without avoid_duplicates' do
      test 'should return lookup_value array with duplicates' do
        key = FactoryBot.create(:lookup_key, :array, :merge_overrides => true, :default_value => [], :path => "organization\nlocation",
          :overrides => {
            "location=#{taxonomies(:location1)}" => ['test'],
            "organization=#{taxonomies(:organization1)}" => ['test'],
          }
        )

        assert_equal({key.id => {key.key => {:value => ['test', 'test'],
                                             :element => ['organization', 'location'],
                                             :element_name => ['Organization 1', 'Location 1']}}},
          Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
      end
    end

    context 'with avoid_duplicates' do
      test 'should return lookup_value array without duplicates' do
        key = FactoryBot.create(:lookup_key, :array, :merge_overrides => true, :avoid_duplicates => true, :default_value => [], :path => "organization\nlocation",
          :overrides => {
            "location=#{taxonomies(:location1)}" => ['test'],
            "organization=#{taxonomies(:organization1)}" => ['test'],
          }
        )

        assert_equal({key.id => {key.key => { :value => ['test'], :element => ['organization', 'location'],
                                              :element_name => ['Organization 1', 'Location 1']}}},
          Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
      end
    end
  end

  context 'hash lookup with merge_overrides' do
    test 'should return lookup_value hash with array of elements' do
      key = FactoryBot.create(:lookup_key, :hash, :with_override,
        :merge_overrides => true,
        :default_value => {},
        :path => "organization\nos\nlocation",
        :overrides => {
          "location=#{taxonomies(:location1)}" => {:example => {:a => 'test'}},
          "organization=#{taxonomies(:organization1)}" => {:example => {:b => 'test2'}},
        }
      )

      assert_equal({key.id => {key.key => {:value => {:example => {:a => 'test', :b => 'test2'}},
                                           :element => ['location', 'organization'],
                                           :element_name => ['Location 1', 'Organization 1']}}},
        Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
    end

    test 'should return lookup_value hash with one element' do
      key = FactoryBot.create(:lookup_key, :hash, :with_override,
        :merge_overrides => true,
        :default_value => {},
        :path => "organization\nos\nlocation",
        :overrides => {
          "organization=#{taxonomies(:organization1)}" => {:example => 'test2'},
          "location=#{taxonomies(:location1)}" => {:example => 'test'},
        }
      )

      assert_equal({key.id => {key.key => {:value => {:example => 'test2'}, :element => ['location', 'organization'],
                                           :element_name => ['Location 1', 'Organization 1']}}},
        Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
    end

    test 'should obey priority' do
      key = FactoryBot.create(:lookup_key, :hash, :with_override,
        :merge_overrides => true,
        :default_value => {},
        :path => "organization\nos\nlocation",
        :overrides => {
          "location=#{taxonomies(:location1)}" => {:a => 'test'},
          "organization=#{taxonomies(:organization1)}" => {:example => {:b => 'test2'}},
          "os=#{operatingsystems(:redhat)}" => {:example => {:b => 'test3'}},
        }
      )

      assert_equal({key.id => {key.key => {:value => {:a => 'test', :example => {:b => 'test2'}},
                                           :element => ['location', 'os', 'organization'],
                                           :element_name => ['Location 1', 'Redhat 6.1', 'Organization 1']}}},
        Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => key.id)).raw)
    end

    test 'should return lookup_value hash with array of elements' do
      key = FactoryBot.create(:lookup_key, :hash, :with_override,
        :merge_overrides => true,
        :default_value => {},
        :path => "organization\nos\nlocation",
        :overrides => {
          "location=#{@host.location}" => {:example => {:a => 'test'}},
          "organization=#{@host.organization}" => {:example => {:b => 'test2'}},
          "os=#{@host.operatingsystem}" => {:example => {:a => 'test3'}},
        }
      )

      assert_equal({key.id => {key.key => {:value => {:example => {:a => 'test3', :b => 'test2'}},
                                           :element => ['location', 'os', 'organization'],
                                           :element_name => ['Location 1', 'Redhat 6.1', 'Organization 1']}}},
        Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => key.id)).raw)
    end

    test 'should return lookup_value hash with array of elements' do
      key = FactoryBot.create(:lookup_key, :hash, :with_override,
        :merge_overrides => true,
        :default_value => {},
        :path => "organization\nos\nlocation",
        :overrides => {
          "location=#{@host.location}" => {:example => {:a => 'test'}},
          "organization=#{@host.organization}" => {:example => {:b => 'test2'}},
        }
      )

      assert_equal({key.id => {key.key => {:value => {:example => {:a => 'test', :b => 'test2'}},
                                           :element => ['location', 'organization'],
                                           :element_name => ['Location 1', 'Organization 1']}}},
        Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => key.id)).raw)
    end

    context 'without merge_default' do
      test 'should not merge with default value' do
        key = FactoryBot.create(:lookup_key, :hash, :with_override,
          :merge_overrides => true,
          :default_value => { :default => 'default' },
          :path => "organization\nos\nlocation",
          :overrides => { "organization=#{@host.organization}" => {:a => 'test2'} }
        )

        assert_equal({key.id => {key.key => {:value => {:a => 'test2' },
                                             :element => ['organization'],
                                             :element_name => ['Organization 1']}}},
          Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => key.id)).raw)
      end
    end

    context 'with merge_default' do
      test 'should merge all values including default' do
        key = FactoryBot.create(:lookup_key, :hash, :with_override,
          :merge_overrides => true,
          :merge_default => true,
          :default_value => { :default => 'default' },
          :path => "organization\nos\nlocation",
          :overrides => {
            "location=#{@host.location}" => {:example => {:a => 'test'}},
            "organization=#{@host.organization}" => {:example => {:b => 'test2'}},
          }
        )

        assert_equal({key.id => {key.key => {:value => {:default => 'default', :example => {:a => 'test', :b => 'test2'}},
                                             :element => ['Default value', 'location', 'organization'],
                                             :element_name => ['Default value', 'Location 1', 'Organization 1']}}},
          Classification::ValuesHashQuery.values_hash(@host, LookupKey.where(:id => [key])).raw)
      end
    end
  end

  test 'type cast allows nil values' do
    key = FactoryBot.create(:lookup_key)
    assert_nothing_raised do
      Classification::ClassificationResult.new(nil, {}).send(:type_cast, key, nil)
    end
  end

  context 'lookup value type cast error' do
    test 'TypeError exceptions are logged' do
      lookup_key = mock('lookup_key')
      Foreman::Parameters::Caster.any_instance.expects(:cast).raises(TypeError)
      lookup_key.expects(:key_type).twice.returns('footype')
      Rails.logger.expects(:warn).with('Unable to type cast bar to footype')
      Classification::ClassificationResult.new(nil, {}).send(:type_cast, lookup_key, 'bar')
    end
  end
end
