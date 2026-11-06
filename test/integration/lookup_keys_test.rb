require 'integration_test_helper'
require 'lookup_keys_test_helper'

class LookupKeysIntegrationTest < ActionDispatch::IntegrationTest
  test 'JSON overrides survive real form parsing and POST method override' do
    key = FactoryBot.create(:lookup_key, :integer, path: 'comment', type: 'DummyLookupKey')
    values = Array.new(LARGE_OVERRIDE_COUNT) do |index|
      { 'match' => "comment=override#{index}", 'value' => '4', 'omit' => '0' }
    end
    body = Rack::Utils.build_nested_query(
      'dummy_lookup_key' => { 'override' => '1', 'lookup_values_json' => values.to_json },
      '_method' => 'patch'
    )
    assert_equal 3, body.split('&').length

    # Pass an encoded body, not a params hash: Rack must parse the form to
    # recover _method before Rails can route this POST to the update action.
    cookies[:test_user] = users(:admin).login
    post dummy_lookup_key_path(key), params: body,
      headers: { 'CONTENT_TYPE' => 'application/x-www-form-urlencoded' }
    assert_redirected_to dummy_lookup_keys_path
    assert_equal 'PATCH', request.request_method
    assert_equal LARGE_OVERRIDE_COUNT, key.reload.override_values.count
    assert_equal values.map { |value| value['match'] }.sort, key.override_values.pluck(:match).sort
    assert_equal [4], key.override_values.pluck(:value).uniq
  end
end
