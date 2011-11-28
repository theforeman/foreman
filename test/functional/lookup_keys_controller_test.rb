require 'test_helper'

class LookupKeysControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns(:lookup_keys)
  end

  test "should get edit" do
    get :edit, {:id => lookup_keys(:one).to_param, :puppetclass_id => puppetclasses(:one).id}, set_session_user
    assert_response :success
  end

  test "should update lookup_keys" do
    put :update, {:id => lookup_keys(:one).to_param, :puppetclass_id => puppetclasses(:one).id, :lookup_key => { :key => "test that" }}, set_session_user
    assert_redirected_to lookup_keys_path
  end

  test "should destroy lookup_keys" do
    assert_difference('LookupKey.count', -1) do
      delete :destroy, {:id => lookup_keys(:one).to_param}, set_session_user
    end

    assert_redirected_to lookup_keys_path
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit an external variable' do
    setup_user
    get :edit, {:id => LookupKey.first.id}
    assert_equal response.status, 403
  end

  test 'user with viewer rights should succeed in viewing external variables' do
    setup_user
    get :index
    assert_response :success
  end
end
