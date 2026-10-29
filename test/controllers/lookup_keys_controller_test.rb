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

  test '#update adds a large number of overrides via JSON' do
    values = Array.new(LARGE_OVERRIDE_COUNT) { |index| new_value_params.merge('match' => "comment=override#{index}") }
    params = { override: true, path: 'comment', lookup_values_json: values.to_json }
    patch :update, params: { id: key.to_param, dummy_lookup_key: params }, session: set_session_user
    assert_redirected_to dummy_lookup_keys_path

    assert_equal LARGE_OVERRIDE_COUNT, key.reload.override_values.count
    assert_equal values.map { |value| value['match'] }.sort, key.override_values.pluck(:match).sort
    assert_equal [4], key.override_values.pluck(:value).uniq
  end

  test '#update deletes values via JSON' do
    params = { override: true, lookup_values_json: [destroy_params].to_json }
    assert_difference -> { key_with_value.override_values.count }, -1 do
      patch :update, params: { id: key_with_value.to_param, dummy_lookup_key: params }, session: set_session_user
      assert_redirected_to dummy_lookup_keys_path
    end
  end

  test '#update handles match conflict via JSON' do
    params = { override: true, lookup_values_json: [new_value_params, new_value_params, destroy_params].to_json }
    patch :update, params: { id: key_with_value.to_param, dummy_lookup_key: params }, session: set_session_user
    assert_response :success
    assert_equal 1, key_with_value.reload.override_values.count
    assert assigns(:dummy_lookup_key).lookup_values.any? { |value| value.errors.any? }
  end

  test '#update reconciles deleting and recreating the same match via JSON' do
    existing = key_with_value.override_values.first
    replacement = new_value_params.merge('match' => existing.match, '_destroy' => 'false')
    removed = destroy_params.merge('match' => existing.match)
    params = { override: true, lookup_values_json: [removed, replacement].to_json }
    patch :update, params: { id: key_with_value.to_param, dummy_lookup_key: params }, session: set_session_user
    assert_redirected_to dummy_lookup_keys_path
    assert_equal [existing.id], key_with_value.reload.override_values.pluck(:id)
    assert_equal 4, key_with_value.override_values.first.value
  end

  test '#update preserves per-row validation errors via JSON' do
    params = { override: true, lookup_values_json: [new_value_params.merge('value' => 'invalid')].to_json }
    patch :update, params: { id: key.to_param, dummy_lookup_key: params }, session: set_session_user
    assert_response :success
    value = assigns(:dummy_lookup_key).lookup_values.detect { |override| override.match == 'hostgroup=db' }
    assert value.errors.any?
    assert_equal 0, key.reload.override_values.count
  end

  test '#update rejects malformed lookup values JSON' do
    ['{', '{}', '[1]', 'null'].each do |payload|
      patch :update, params: { id: key.to_param, dummy_lookup_key: { lookup_values_json: payload } }, session: set_session_user
      assert_response :success
      assert_match 'Invalid lookup values JSON', flash[:error]
      assert_equal 0, key.reload.override_values.count
    end
  end

  test '#update rejects malformed JSON matcher rows before nested assignment' do
    [{}, { 'match' => nil }, { 'match' => 1 }, { 'match' => {} }, { 'match' => '' }, { 'match' => ' ' }].each do |row|
      patch :update, params: { id: key.to_param, dummy_lookup_key: { lookup_values_json: [row].to_json } }, session: set_session_user
      assert_response :success
      assert_match 'Invalid lookup values JSON', flash[:error]
      assert_equal 0, key.reload.override_values.count
    end
  end

  test '#update rejects JSON over the byte limit before parsing' do
    payload = ' ' * (LookupKeysController::MAX_LOOKUP_VALUES_JSON_BYTES + 1)
    JSON.expects(:parse).never
    patch :update, params: { id: key.to_param, dummy_lookup_key: { lookup_values_json: payload } }, session: set_session_user
    assert_response :success
    assert_match 'Invalid lookup values JSON', flash[:error]
    assert_equal 0, key.reload.override_values.count
  end

  test '#update rejects JSON over the row limit before assignment' do
    values = Array.new(LookupKeysController::MAX_LOOKUP_VALUES_JSON_ROWS + 1, new_value_params)
    patch :update, params: { id: key.to_param, dummy_lookup_key: { lookup_values_json: values.to_json } }, session: set_session_user
    assert_response :success
    assert_match 'Invalid lookup values JSON', flash[:error]
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
