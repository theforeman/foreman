require 'test_helper'

class LookupKeyTest < ActiveSupport::TestCase
  should validate_presence_of(:key)
  should validate_inclusion_of(:validator_type).
    in_array(LookupKey::VALIDATOR_TYPES).allow_blank.allow_nil.
    with_message('invalid')
  should validate_inclusion_of(:key_type).
    in_array(LookupKey::KEY_TYPES).allow_blank.allow_nil.
    with_message('invalid')

  describe '#path_elements' do
    test 'element separation' do
      key = FactoryBot.create(:lookup_key, key: 'ntp', path: "domain,hostgroup\n domain")
      elements = key.path_elements
      assert_equal 'domain', elements[0][0]
      assert_equal 'hostgroup', elements[0][1]
      assert_equal 'domain', elements[1][0]
    end
  end

  test 'default_value should not be casted if override is false' do
    param = FactoryBot.build(:lookup_key, :boolean, override: false, default_value: 't')
    param.save
    assert_equal 't', param.default_value
    param.update(override: true)
    assert_equal true, param.default_value
  end

  describe '#default_value_before_type_cast' do
    test 'nil value should remain nil' do
      param = FactoryBot.build_stubbed(:lookup_key, override: true, default_value: nil)
      assert param.valid?
      assert_nil param.default_value
      assert_nil param.default_value_before_type_cast
    end

    test 'boolean value should remain casted' do
      param = FactoryBot.build_stubbed(:lookup_key, :boolean, override: true, default_value: 'false')
      assert param.valid?
      assert_equal false, param.default_value
      assert_equal false, param.default_value_before_type_cast
    end

    test 'array value should be an unchanged string' do
      param = FactoryBot.build_stubbed(:lookup_key, :array, override: true, default_value: '["test"]')
      assert param.valid?
      assert_equal ['test'], param.default_value
      assert_equal '["test"]', param.default_value_before_type_cast
    end

    test 'JSON value should be an unchanged string' do
      param = FactoryBot.build_stubbed(:lookup_key, override: true, key_type: 'json', default_value: '["test"]')
      default = param.default_value
      assert param.valid?
      assert_equal ['test'], param.default_value
      assert_equal default, param.default_value_before_type_cast
    end

    test 'hash value should be an unchanged string' do
      param = FactoryBot.build_stubbed(:lookup_key, override: true, key_type: 'hash', default_value: "foo: bar\n")
      assert param.valid?
      assert_equal({'foo' => 'bar'}, param.default_value)
      assert_equal "foo: bar\n", param.default_value_before_type_cast
    end

    test 'YAML value should be an unchanged string' do
      param = FactoryBot.build_stubbed(:lookup_key, :yaml, override: true, default_value: "- test\n")
      assert param.valid?
      assert_equal ['test'], param.default_value
      assert_equal "- test\n", param.default_value_before_type_cast
    end

    test 'uncast value containing ERB should be an unchanged string' do
      param = FactoryBot.build_stubbed(:lookup_key, :array, override: true, default_value: '["<%= @host.name %>"]')
      assert param.valid?
      assert_equal '["<%= @host.name %>"]', param.default_value
      assert_equal '["<%= @host.name %>"]', param.default_value_before_type_cast
    end

    test "when invalid, just returns the invalid value" do
      val = '{"foo" => "bar"}'
      param = FactoryBot.build_stubbed(:lookup_key, override: true, key_type: 'hash', default_value: val)
      refute param.valid?
      assert_equal val, param.default_value_before_type_cast
    end

    test "white space isn't stripped" do
      val = <<~EOF

        this is a multiline value
        with leading and trailing whitespace

      EOF
      param = FactoryBot.build_stubbed(:lookup_key, override: true, default_value: val)
      assert param.valid?
      assert_equal val, param.default_value_before_type_cast
    end
  end

  test "this is not a smart class parameter?" do
    assert_not_deprecated do
      refute FactoryBot.build_stubbed(:lookup_key).puppet?
    end
  end

  test "to_param should replace whitespace with underscore" do
    lookup_key = LookupKey.new(key: 'enhanced variable', path: 'hostgroup', default_value: 'default')
    assert_equal '-enhanced_variable', lookup_key.to_param
  end

  test "should not be able to merge overrides for a string" do
    key = FactoryBot.build_stubbed(:lookup_key, override: true, merge_overrides: true)
    refute_valid key
    assert_equal key.errors[:merge_overrides].first, _("can only be set for array, hash, json or yaml")
  end

  test "should be able to merge overrides and merge_default for a hash" do
    key = FactoryBot.build_stubbed(:lookup_key, :hash, override: true, merge_overrides: true, merge_default: true)
    assert_valid key
  end

  test "should not be able to avoid duplicates for a hash" do
    key = FactoryBot.build_stubbed(:lookup_key, :hash, override: true, merge_overrides: true, avoid_duplicates: true)
    refute_valid key
    assert_equal key.errors[:avoid_duplicates].first, _("can only be set for arrays that have merge_overrides set to true")
  end

  test "should not be able to merge default when merge_override is false" do
    key = FactoryBot.build_stubbed(:lookup_key, :hash, override: true, merge_overrides: false, merge_default: true, default_value: {})
    refute_valid key
    assert_equal "can only be set when merge overrides is set", key.errors[:merge_default].first
  end

  test "should be able to merge_overrides and avoid_duplicates for a array" do
    key = FactoryBot.build_stubbed(:lookup_key, :array, override: true, merge_overrides: true, avoid_duplicates: true, default_value: [])
    assert_valid key
  end

  test "should not be able to avoid duplicates when merge_override is false" do
    key = FactoryBot.build_stubbed(:lookup_key, :array, override: true, merge_overrides: false, avoid_duplicates: true, default_value: [])
    refute_valid key
    assert_equal key.errors[:avoid_duplicates].first, _("can only be set for arrays that have merge_overrides set to true")
  end

  test "array key is valid even with string value containing erb" do
    key = FactoryBot.build_stubbed(:lookup_key, :array, override: true, default_value: '<%= [1,2,3] %>')
    assert_valid key
  end

  test "array key is invalid with string value without erb" do
    key = FactoryBot.build_stubbed(:lookup_key, :array, override: true, default_value: 'whatever')
    refute_valid key
    assert_include key.errors.attribute_names, :default_value
  end

  test "safe_value can be shown for key" do
    key = FactoryBot.build_stubbed(:lookup_key, hidden_value: false, override: true, key_type: 'string', default_value: 'aaa')
    assert_equal key.default_value, key.safe_value
    key.hidden_value = true
    assert_equal key.hidden_value, key.safe_value
  end

  test "override params are reset after override changes back to false" do
    key = FactoryBot.create(:lookup_key, :array, override: true, omit: true)
    override_params = [:merge_overrides, :merge_default, :avoid_duplicates]

    override_params.each { |param| key.send("#{param}=", true) }
    key.save

    key.override = false
    key.description = "Gregor Samsa"
    assert key.save

    override_params.each do |param|
      refute key.read_attribute(param)
    end
  end

  test "#overridden? works for unsaved hosts" do
    key = FactoryBot.create(:lookup_key)
    host = FactoryBot.build_stubbed(:host)
    refute key.overridden?(host)

    host.lookup_values_attributes = {'0' => {'lookup_key_id' => key.id.to_s, '_destroy' => 'false'}}.with_indifferent_access
    assert_equal 1, host.lookup_values.size
    assert key.overridden?(host)
  end

  test 'sorted_values returns correctly ordered values' do
    overrides = { 'os=test' => 'aaa', 'os=test2,model=a' => 'aaa', 'model=testmodel' => 'aaa', 'arch=testarcg' => 'aaa', 'arch=testaaaa' => 'bcd' }
    sorted_matches = ['model=testmodel', 'os=test', 'arch=testaaaa', 'arch=testarcg', 'os=test2,model=a']
    key = FactoryBot.create(:lookup_key, :with_override, path: "model\nos\r\narch\nos,model", override: true, overrides: overrides)

    refute_equal(sorted_matches, key.lookup_values.reload.map(&:match))
    assert_equal(sorted_matches, key.sorted_values.map(&:match))
  end

  test 'should not update with invalid parameter types' do
    invalid_parameters_data = [
      {
        :sc_type => 'boolean',
        :value => RFauxFactory.gen_alphanumeric,
      },
      {
        :sc_type => 'integer',
        :value => RFauxFactory.gen_utf8,
      },
      {
        :sc_type => 'real',
        :value => RFauxFactory.gen_utf8,
      },
      {
        :sc_type => 'array',
        :value => '0',
      },
      {
        :sc_type => 'hash',
        :value => 'a:test',
      },
      {
        :sc_type => 'yaml',
        :value => '@@',
      },
      {
        :sc_type => 'json',
        :value => RFauxFactory.gen_alpha,
      },
    ]
    lookup_key = FactoryBot.create(:lookup_key, override: true)
    invalid_parameters_data.each do |data|
      lookup_key.parameter_type = data[:sc_type]
      lookup_key.default_value = data[:value]
      refute lookup_key.valid?, "Can update lookup key with invalid data #{data}"
      assert_includes lookup_key.errors.attribute_names, :default_value
    end
  end

  test 'should update with valid parameter types' do
    valid_parameters_data = [
      {
        :sc_type => 'string',
        :value => RFauxFactory.gen_utf8,
      },
      {
        :sc_type => 'boolean',
        :value => ['0', '1'].sample,
      },
      {
        :sc_type => 'integer',
        :value => rand(1000..1 << 64),
      },
      {
        :sc_type => 'real',
        :value => -123.0,
      },
      {
        :sc_type => 'array',
        :value => "[#{RFauxFactory.gen_alpha}, #{RFauxFactory.gen_numeric_string.to_i}, #{RFauxFactory.gen_boolean}]",
      },
      {
        :sc_type => 'hash',
        :value => "{{'#{RFauxFactory.gen_alpha}': '#{RFauxFactory.gen_alpha}'}}",
      },
      {
        :sc_type => 'yaml',
        :value => 'name=>XYZ',
      },
      {
        :sc_type => 'json',
        :value => '{"name": "XYZ"}',
      },
    ]
    lookup_key = FactoryBot.create(:lookup_key, override: true)
    valid_parameters_data.each do |data|
      lookup_key.parameter_type = data[:sc_type]
      lookup_key.default_value = data[:value]
      assert lookup_key.valid?, "Can't update lookup key with valid data #{data}"
    end
  end

  test "can create lookup key with long default_value" do
    as_user :one do
      lookup_key = FactoryBot.build(:lookup_key, override: true, default_value: 'a' * 280)
      assert_valid lookup_key
    end
  end

  test 'validation rebuilds and expires match indexes while restoring nested and independent parent contexts' do
    key = FactoryBot.build(:lookup_key, path: 'comment')
    first = key.lookup_values.build(match: 'comment=first', value: 'one')
    second = key.lookup_values.build(match: 'comment=first', value: 'two')
    refute key.save
    assert_nil key.instance_variable_get(:@lookup_value_validation_context)

    second.match = 'comment=second'
    assert_valid key
    third = key.lookup_values.build(match: first.match, value: 'three')
    refute_valid key
    key.lookup_values.target.delete(third)
    assert_valid key
    second.match = first.match
    refute_valid key
    second.mark_for_destruction
    refute_valid key
    assert first.errors.added?(:match, :taken)
    assert_nil key.instance_variable_get(:@lookup_value_validation_context)

    key = FactoryBot.build(:lookup_key, path: 'comment')
    value = key.lookup_values.build(match: 'comment=first', value: 'one')
    key.define_singleton_method(:validate_default_value) do
      lookup_value_match_taken?(value)
      raise 'validation interrupted'
    end
    key.override = true
    error = assert_raises(RuntimeError) { key.valid? }
    assert_equal 'validation interrupted', error.message
    assert_nil key.instance_variable_get(:@lookup_value_validation_context)
    key.singleton_class.remove_method(:validate_default_value)
    assert_valid key

    key = FactoryBot.build(:lookup_key, path: 'comment')
    value = key.lookup_values.build(match: 'comment=first', value: 'one')
    key.define_singleton_method(:sanitize_path) do
      lookup_value_match_taken?(value)
      throw :abort
    end
    refute_valid key
    assert_nil key.instance_variable_get(:@lookup_value_validation_context)
    key.singleton_class.remove_method(:sanitize_path)
    assert_valid key

    key = FactoryBot.build(:lookup_key, path: 'comment')
    outer = { index: {} }
    key.instance_variable_set(:@lookup_value_validation_context, outer)
    assert_valid key
    assert_same outer, key.instance_variable_get(:@lookup_value_validation_context)

    first = FactoryBot.build(:lookup_key, path: 'comment')
    second = FactoryBot.build(:lookup_key, path: 'comment')
    first.lookup_values.build(match: 'comment=Same', value: 'one')
    second.lookup_values.build(match: 'comment=Same', value: 'two')
    first.define_singleton_method(:validate_default_value) { second.valid? }
    first.override = true
    assert_valid first
    assert_nil first.instance_variable_get(:@lookup_value_validation_context)
    assert_nil second.instance_variable_get(:@lookup_value_validation_context)
  ensure
    key&.instance_variable_set(:@lookup_value_validation_context, nil)
  end

  test 'SQL uniqueness still rejects reusing a persisted match marked for deletion' do
    key = FactoryBot.create(:lookup_key, :with_override)
    old = key.lookup_values.to_a.first
    old.mark_for_destruction
    replacement = key.lookup_values.build(match: old.match, value: 'new')
    assert key.lookup_value_match_taken?(replacement)
    refute key.save
    assert replacement.errors.added?(:match, :taken, value: replacement.match)
    assert LookupValue.exists?(old.id)
    assert_nil key.instance_variable_get(:@lookup_value_validation_context)
  end

  test 'parent validation match reads scale linearly with the number of children' do
    counts = [128, 256].map do |size|
      key = FactoryBot.build(:lookup_key, path: 'comment')
      values = Array.new(size) do |index|
        key.lookup_values.build(match: "comment=scaling#{index}", value: 'override')
      end
      reads = 0
      values.each do |value|
        reader = value.method(:match)
        value.define_singleton_method(:match) do
          reads += 1
          reader.call
        end
      end
      assert_valid key
      assert_operator reads, :>, 0, "No match reads measured for #{size} children"
      assert_operator reads, :<=, size * 80, "#{reads} match reads for #{size} children"
      reads
    end
    assert_operator counts.last, :<=, counts.first * 2.25, "Match reads: #{counts.inspect}"
    assert_operator counts.last, :>=, counts.first * 1.75, "Match reads: #{counts.inspect}"
  end

  test 'taken errors match the original sibling scan throughout randomized parent validation' do
    persisted_key = FactoryBot.create(:lookup_key, path: "comment\ndomain\ncomment,domain")
    persisted = ['comment=Mixed', 'comment=other'].map do |match|
      persisted_key.lookup_values.create!(match: match, value: 'override')
    end
    matches = [nil, '', '   ', 'comment=Mixed', 'COMMENT=Mixed', ' COMMENT = Mixed ',
               'comment=mixed', 'Comment = mixed', 'comment=other', 'domain=Example.COM',
               'DOMAIN = Example.COM', 'comment=first=Mixed', 'comment=Mixed=',
               'comment=Mixed,domain=Example.COM', 'COMMENT=Mixed, DOMAIN = Example.COM']
    random = Random.new(39973)
    cases = [
      [{ match: 'comment=Mixed' }, { match: ' COMMENT = Mixed ' }],
      [{ match: 'comment=Mixed' }, { match: 'comment=Mixed', marked: true }],
      [{ match: 'comment=Mixed', record: 0 }, { match: ' COMMENT = Mixed ', record: 0 }, { match: 'comment=Mixed' }],
    ]
    cases.concat(Array.new(200) do
      Array.new(random.rand(1..10)) do
        { match: matches.sample(random: random), record: [nil, nil, 0, 1].sample(random: random), marked: random.rand(5) == 0 }
      end
    end)

    cases.each_with_index do |rows, index|
      [rows, rows.reverse].each do |ordered_rows|
        expected = lookup_value_uniqueness_results(persisted_key, persisted, ordered_rows, reference: true)
        actual = lookup_value_uniqueness_results(persisted_key, persisted, ordered_rows, reference: false)
        assert_equal expected, actual, "Parity case #{index}: #{ordered_rows.inspect}"
      end
    end
  end

  private

  def original_lookup_value_uniqueness(value)
    return if value.lookup_key.nil?
    if value.lookup_key.lookup_values.any? { |sibling| sibling != value && sibling.match == value.match }
      value.errors.add(:match, :taken)
    end
  end

  def lookup_value_uniqueness_results(persisted_key, persisted, rows, reference:)
    key = LookupKey.instantiate(persisted_key.attributes)
    original = method(:original_lookup_value_uniqueness)
    trace = []
    values = rows.each_with_index.map do |row, index|
      value = if row[:record].nil?
                LookupValue.new(value: 'override')
              else
                LookupValue.instantiate(persisted.fetch(row[:record]).attributes)
              end
      value.lookup_key = key
      value.match = row[:match]
      value.mark_for_destruction if row[:marked]
      value.define_singleton_method(:ensure_match_uniqueness) do
        reference ? original.call(self) : super()
        trace << [index, errors.added?(:match, :taken)]
      end
      value
    end
    key.association(:lookup_values).target = values
    key.association(:lookup_values).loaded!
    valid = key.valid?
    taken = values.each_index.select { |index| values[index].errors.details[:match].any? { |error| error[:error] == :taken } }
    [valid, trace, taken, values.map(&:match)]
  end
end
