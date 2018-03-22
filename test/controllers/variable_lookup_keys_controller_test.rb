require 'test_helper'

class VariableLookupKeysControllerTest < ActionController::TestCase
  setup do
    @factory_options = [{:puppetclass => puppetclasses(:one), :override => true, :default_value => 'test'}]
  end

  basic_pagination_per_page_test
  basic_pagination_rendered_test

  test "should get index" do
    get :index, session: set_session_user
    assert_response :success
    assert_not_nil assigns(:lookup_keys)
  end

  test "should get edit" do
    get :edit, params: { :id => lookup_keys(:two).to_param }, session: set_session_user
    assert_response :success
  end

  test "should update variable_lookup_keys" do
    lkey = FactoryBot.create(:variable_lookup_key, :puppetclass => puppetclasses(:one), :override => true, :default_value => 'test')
    put :update, params: { :id => lkey.to_param, :variable_lookup_key => { :description => "test that" } }, session: set_session_user
    assert_redirected_to variable_lookup_keys_path
  end

  test "should destroy variable_lookup_keys" do
    assert_difference('VariableLookupKey.count', -1) do
      delete :destroy, params: { :id => lookup_keys(:two).to_param }, session: set_session_user
    end
    assert_redirected_to variable_lookup_keys_path
  end

  test "should create variable_lookup_keys" do
    puppetclass = FactoryBot.create(:puppetclass)
    assert_difference('VariableLookupKey.count', 1) do
      post :create, params: { :variable_lookup_key => { :key => "dummy", :type => "string", :default_value => 'test', :puppetclass_id => puppetclass.id } }, session: set_session_user
    end
    assert_redirected_to variable_lookup_keys_path
  end

  test 'user with viewer rights should fail to edit an external variable' do
    setup_users
    get :edit, params: { :id => VariableLookupKey.first.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_equal response.status, 403
  end

  test 'user with viewer rights should succeed in viewing external variables' do
    setup_users
    get :index, session: set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end
end
