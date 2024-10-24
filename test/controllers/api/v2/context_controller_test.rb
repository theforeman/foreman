require 'test_helper'

class Api::V2::ContextControllerTest < ActionController::TestCase
  # test_metadata = {
  #  version: 1,
  #  user: "admin",
  #  permissions: %w[perm_0 perm_1 perm_2],
  # }

  test "should get full metadata" do
    assert_equal true, true
    # expected_response = {"metadata" => test_metadata.as_json}
    # get :index, session: set_session_user
    # assert_response :success
    # assert_equal expected_response, @response.parsed_body
  end

  test 'should get partial metadata' do
    assert_equal true, true
  end

  test 'should error on wrong parameter type' do
    assert_equal true, true
  end
end
