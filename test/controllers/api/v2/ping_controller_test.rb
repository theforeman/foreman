require 'test_helper'

class Api::V2::PingControllerTest < ActionController::TestCase
  test 'should get ping results' do
    response = {
      'foreman': {
        database: true,
      },
    }
    Ping.stubs(:ping).returns(response)
    get :ping
    assert_response :success
    assert_not_nil assigns(:results)
    results = ActiveSupport::JSON.decode(@response.body)
    assert_not results.empty?, 'Should response with ping results'
  end

  test 'should get statuses results' do
    statuses = {
      'foreman': {
        version: '1.20.0',
        api: {
          version: 'v2',
        },
      },
    }
    Ping.stubs(:statuses).returns(statuses)
    get :statuses
    assert_response :success
    assert_not_nil assigns(:results)
    results = ActiveSupport::JSON.decode(@response.body)
    assert_not results.empty?, 'Should response with statuses'
  end
end
