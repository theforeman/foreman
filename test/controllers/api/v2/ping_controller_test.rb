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

  test 'should include version headers if setting enabled and user logged in' do
    Setting[:expose_version] = true
    User.current = users(:admin)
    Ping.stubs(:statuses).returns({})
    get :statuses
    assert_equal response.headers['Foreman_version'], SETTINGS[:version].full
    assert_equal 'v2', response.headers['Foreman_api_version']
  end

  test 'should NOT include version headers if setting disabled' do
    Setting[:expose_version] = false
    User.current = users(:admin)
    Ping.stubs(:statuses).returns({})
    get :statuses
    assert_nil response.headers['Foreman_version']
  end

  test 'should NOT include version headers if user is not logged in' do
    Setting[:expose_version] = true
    User.current = nil
    Ping.stubs(:statuses).returns({})
    get :statuses
    assert_nil response.headers['Foreman_version']
  end

  teardown do
    User.current = nil
    Setting[:expose_version] = true
  end
end
