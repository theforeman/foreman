require 'test_helper'

class Api::GraphqlControllerTest < ActionController::TestCase
  test 'empty query' do
    post :execute, params: {}

    assert_response :success
    refute_empty json_errors
    assert_includes json_error_messages, 'No query string was present'
  end
end
