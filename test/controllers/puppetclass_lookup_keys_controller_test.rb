require 'test_helper'

class PuppetclassLookupKeysControllerTest < ActionController::TestCase
  setup do
    @factory_options = [:as_smart_class_param, :puppetclass => puppetclasses(:one), :override => true, :default_value => 'test']
  end

  basic_pagination_rendered_test
  basic_pagination_per_page_test

  test "should get index" do
    get :index, session: set_session_user
    assert_response :success
    assert_not_nil assigns(:lookup_keys)
  end

  test "should get edit" do
    get :edit, params: { :id => lookup_keys(:one).to_param }, session: set_session_user
    assert_response :success
  end

  test "should update lookup_keys" do
    lkey = FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :puppetclass => puppetclasses(:one), :override => true, :default_value => 'test')
    put :update, params: { :id => lkey.to_param, :puppetclass_lookup_key => { :description => "test that" } }, session: set_session_user
    assert_equal 'test that', lkey.reload.description
    assert_redirected_to puppetclass_lookup_keys_path
  end

  test "should destroy lookup_keys" do
    assert_difference('PuppetclassLookupKey.count', -1) do
      delete :destroy, params: { :id => lookup_keys(:one).to_param }, session: set_session_user
    end
    assert_redirected_to puppetclass_lookup_keys_path
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.default, Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit an external variable' do
    setup_user
    get :edit, params: { :id => PuppetclassLookupKey.first.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_equal response.status, 403
  end

  test 'user with viewer rights should succeed in viewing external variables' do
    setup_user
    get :index, session: set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end
end
