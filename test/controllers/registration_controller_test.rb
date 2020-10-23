require 'test_helper'

class RegistrationControllerTest < ActionController::TestCase
  test 'new' do
    get :new, session: set_session_user
    assert_response :success
    assert_template :new
  end

  test 'create' do
    params = { organization: taxonomies(:organization1).id, location: taxonomies(:location1).id }
    post :create, params: params, session: set_session_user

    assert_response :success
    assert_template :create
  end
end
