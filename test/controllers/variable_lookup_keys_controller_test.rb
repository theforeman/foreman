require 'test_helper'

class VariableLookupKeysControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns(:lookup_keys)
  end

  test "should get edit" do
    get :edit, {:id => lookup_keys(:two).to_param}, set_session_user
    assert_response :success
  end

  test "should update variable_lookup_keys" do
    lkey = FactoryGirl.create(:variable_lookup_key, :puppetclass => puppetclasses(:one), :override => true, :default_value => 'test')
    put :update, {:id => lkey.to_param, :variable_lookup_key => { :description => "test that" }}, set_session_user
    assert_redirected_to variable_lookup_keys_path
  end

  test "should destroy variable_lookup_keys" do
    assert_difference('VariableLookupKey.count', -1) do
      delete :destroy, {:id => lookup_keys(:two).to_param}, set_session_user
    end
    assert_redirected_to variable_lookup_keys_path
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.default, Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit an external variable' do
    setup_user
    get :edit, {:id => VariableLookupKey.first.id}, set_session_user.merge(:user => users(:one).id)
    assert_equal response.status, 403
  end

  test 'user with viewer rights should succeed in viewing external variables' do
    setup_user
    get :index, {}, set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end
end
