require 'lookup_keys_test_helper'

class LookupKeysControllerTest < ActionController::TestCase
  tests DummyLookupKeysController

  let(:key) { FactoryBot.create(:lookup_key, :integer, :type => 'DummyLookupKey') }
  let(:key_with_value) { FactoryBot.create(:lookup_key, :integer, :with_override, :path => "hostgroup\ncomment", :type => 'DummyLookupKey') }
  let(:new_value_params) { { 'match' => 'hostgroup=db', 'value' => '4', 'omit' => '0' } }
  let(:destroy_params) { { 'id' => key_with_value.override_values.first.id, '_destroy' => '1' } }

  test '#update adds valid override' do
    assert_equal key.override_values.count, 0
    params = { :override => true, :lookup_values_attributes => { '112' => new_value_params }}
    patch :update, params: { :id => key.to_param, :dummy_lookup_key => params }, session: set_session_user
    assert_redirected_to dummy_lookup_keys_path

    assert_equal key.reload.override_values.count, 1
    value = key.override_values.first
    assert_equal 'hostgroup=db', value.match
    assert_equal 4, value.value
  end

  test '#update deletes values' do
    params = { :override => true, :lookup_values_attributes => { '0' => destroy_params }}
    assert_difference -> { key_with_value.override_values.count }, -1 do
      patch :update, params: { :id => key_with_value.to_param, :dummy_lookup_key => params }, session: set_session_user
      assert_redirected_to dummy_lookup_keys_path
    end
  end

  test '#update creates and deletes values simultanously' do
    params = { :override => true, :lookup_values_attributes => { '0' => destroy_params, '112' => new_value_params }}
    patch :update, params: { :id => key_with_value.to_param, :dummy_lookup_key => params }, session: set_session_user
    assert_redirected_to dummy_lookup_keys_path
    assert_equal key_with_value.reload.override_values.count, 1
    new_val = key_with_value.override_values.first
    assert_equal 4, new_val.value
    assert_equal 'hostgroup=db', new_val.match
  end

  test '#update handle match conflict' do
    params = { :override => true, :lookup_values_attributes => { '112' => new_value_params,
                                                                 '113' => new_value_params,
                                                                 '0' => destroy_params }}
    patch :update, params: { :id => key_with_value.to_param, :dummy_lookup_key => params }, session: set_session_user
    assert_response :success
    assert_equal 1, key_with_value.reload.override_values.count
  end

  test '#update mixes creates updates and id only deletes via JSON' do
    deleted = key_with_value.override_values.first
    updated = key_with_value.lookup_values.create!(match: 'comment=updated', value: 5)
    rows = [
      { 'id' => deleted.id, '_destroy' => true },
      { 'id' => updated.id, 'match' => updated.match, '_destroy' => true },
      { 'id' => updated.id, 'match' => updated.match, 'value' => '8', '_destroy' => false },
      new_value_params,
    ]
    patch :update, params: { id: key_with_value.to_param, dummy_lookup_key: { override: true, lookup_values_json: rows.to_json } }, session: set_session_user
    assert_redirected_to dummy_lookup_keys_path
    refute LookupValue.exists?(deleted.id)
    assert_equal 8, updated.reload.value
    assert_equal ['comment=updated', 'hostgroup=db'], key_with_value.reload.lookup_values.pluck(:match).sort
    assert_equal [updated.id], key_with_value.lookup_values.where(match: updated.match).pluck(:id)

    attrs = {
      'd0' => { 'id' => '10', 'match' => 'comment=A', '_destroy' => '1', 'omit' => '1' },
      'r0' => { 'id' => '20', 'match' => 'comment=A', 'value' => 'first', '_destroy' => '0' },
      'd1' => { 'id' => '11', 'match' => 'comment=A', '_destroy' => '1' },
      'other' => { 'match' => 'comment=B', 'value' => 'untouched' },
      'r1' => { 'match' => 'comment=A', 'value' => 'second', '_destroy' => '0' },
      'd2' => { 'id' => '12', 'match' => 'comment=A', '_destroy' => '1' },
      'd3' => { 'id' => '13', 'match' => 'comment=A', '_destroy' => '1' },
      'raw_deleted' => { 'id' => '14', 'match' => ' COMMENT = C ', '_destroy' => '1' },
      'id_only' => { 'id' => '15', '_destroy' => '1' },
      'raw_kept' => { 'match' => 'comment=C', 'value' => 'new' },
    }
    original = attrs.deep_dup
    result = @controller.send(:sanitize_attrs, attrs)
    assert_equal ['d0', 'd1', 'd2', 'd3', 'raw_deleted', 'id_only', 'other', 'raw_kept'], result.keys
    assert_equal attrs['d0'], result['d0']
    assert_equal attrs['d1'], result['d1']
    assert_equal({ 'id' => '20', 'match' => 'comment=A', '_destroy' => '0', 'value' => 'first', 'omit' => '1' }, result['d2'])
    assert_equal({ 'id' => '11', 'match' => 'comment=A', '_destroy' => '0', 'value' => 'second' }, result['d3'])
    assert_equal attrs['other'], result['other']
    ['raw_deleted', 'id_only', 'raw_kept'].each { |name| assert_equal attrs[name], result[name] }
    assert_equal original, attrs
  end

  test '#update rejects malformed and oversized-by-bytes lookup values JSON' do
    malformed_rows = [{}, { match: nil }, { match: 1 }, { match: {} }, { match: '' }, { match: ' ' }]
    payloads = ['{', '{}', '[1]', 'null'] + malformed_rows.map { |row| [row].to_json }
    payloads.each do |payload|
      flash.clear
      patch :update, params: { id: key.to_param, dummy_lookup_key: { lookup_values_json: payload } }, session: set_session_user
      assert_response :success
      assert flash[:error].present?
      assert_equal 0, key.reload.override_values.count
    end

    flash.clear
    payload = ' ' * (LookupKeysController::MAX_LOOKUP_VALUES_JSON_BYTES + 1)
    JSON.expects(:parse).never
    patch :update, params: { id: key.to_param, dummy_lookup_key: { lookup_values_json: payload } }, session: set_session_user
    assert_response :success
    assert flash[:error].present?
    assert_equal 0, key.reload.override_values.count
  end

  test '#update preserves omitted integer and array types and casts when omit is cleared' do
    lookup_keys = [:integer, :array].map do |type|
      FactoryBot.create(:lookup_key, type, :with_override, type: 'DummyLookupKey')
    end
    lookup_keys.each do |lookup_key|
      value = lookup_key.override_values.first
      original = value.value
      value.update!(omit: true)
      row = { 'id' => value.id, 'match' => value.match, 'omit' => true }
      patch :update, params: { id: lookup_key.to_param, dummy_lookup_key: { lookup_values_json: [row].to_json } }, session: set_session_user
      assert_redirected_to dummy_lookup_keys_path
      assert_equal original, value.reload.value
      assert_instance_of original.class, value.value

      row['omit'] = false
      row['value'] = lookup_key.key_type == 'integer' ? '8' : '[1, 2]'
      patch :update, params: { id: lookup_key.to_param, dummy_lookup_key: { lookup_values_json: [row].to_json } }, session: set_session_user
      assert_redirected_to dummy_lookup_keys_path
      assert_equal(lookup_key.key_type == 'integer' ? 8 : [1, 2], value.reload.value)
    end
  end

  test 'standalone edit opts into JSON transport' do
    prepare_lookup_key_view
    get :edit, params: { id: key_with_value.to_param }, session: set_session_user
    assert_response :success
    assert_select 'form[data-lookup-values-json="true"]' do
      assert_select 'input.lookup_values_json[name="dummy_lookup_key[lookup_values_json]"]', 1
    end
  end

  test 'nested puppet style fields retain nested attributes without JSON transport' do
    prepare_lookup_key_view
    get :edit, params: { id: key_with_value.to_param, nested: true }, session: set_session_user
    assert_response :success
    assert_select '[data-lookup-values-json]', 0
    assert_select 'input.lookup_values_json', 0
    assert_select 'input[name^="puppetclass[class_params_attributes][0][lookup_values_attributes]"]'
  end

  test '#update renders the invalid value and inline row error then accepts a correction' do
    prepare_lookup_key_view
    @controller.render_real_edit = true
    row = new_value_params.merge('value' => 'invalid-integer')
    patch :update, params: { id: key.to_param, dummy_lookup_key: { override: true, lookup_values_json: [row].to_json } }, session: set_session_user
    assert_response :success
    invalid = assigns(:dummy_lookup_key).lookup_values.detect { |value| value.match == row['match'] }
    assert invalid.errors[:value].present?
    assert_select 'tr.matchers.has-error' do
      assert_select 'textarea[data-property="value"]', text: 'invalid-integer'
    end
    assert_select 'tr.has-error:not(.matchers) .help-block', text: invalid.errors.full_messages.to_sentence
    assert_equal 0, key.reload.override_values.count

    row['value'] = '8'
    patch :update, params: { id: key.to_param, dummy_lookup_key: { override: true, lookup_values_json: [row].to_json } }, session: set_session_user
    assert_redirected_to dummy_lookup_keys_path
    assert_equal 8, key.reload.override_values.first.value
  end

  private

  def prepare_lookup_key_view
    # Core's dummy key has no Puppet environment/class associations. Stub only
    # those unrelated details while rendering the real shared form partials.
    DummyLookupKey.any_instance.stubs(:environment_classes).returns([])
    DummyLookupKey.any_instance.stubs(:required).returns(false)
    @controller.view_context_class.any_instance.stubs(:show_puppet_class).returns(nil)
  end
end
