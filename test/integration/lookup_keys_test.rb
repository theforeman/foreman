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

  test 'legacy override form exceeds the active Rack parameter limit' do
    values = Array.new(LARGE_OVERRIDE_COUNT) do |index|
      [index.to_s, { 'match' => "comment=override#{index}", 'value' => '4', 'omit' => '0' }]
    end.to_h
    body = Rack::Utils.build_nested_query(
      'dummy_lookup_key' => { 'override' => '1', 'lookup_values_attributes' => values },
      '_method' => 'patch'
    )

    # Use the active parser without changing its limits. Environments with an
    # older Rack or a raised RACK_QUERY_PARSER_PARAMS_LIMIT may accept this body;
    # there the other test still verifies the JSON transport through Rack.
    begin
      env = Rack::MockRequest.env_for('/dummy_lookup_keys/1',
        :method => 'POST', :input => body, 'CONTENT_TYPE' => 'application/x-www-form-urlencoded')
      Rack::Request.new(env).POST
    rescue Rack::QueryParser::QueryLimitError => error
      assert_match /number of query parameters/, error.message
      return
    end
    skip 'The active Rack parser does not reject this legacy form at its configured limit'
  end
end
