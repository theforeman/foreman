require 'test_helper'

class CommonParametersControllerTest < ActionController::TestCase
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  def test_index
    get :index, session: set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, session: set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    CommonParameter.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :common_parameter => {:name => nil} }, session: set_session_user
    assert_template 'new'
  end

  def test_create_valid
    CommonParameter.any_instance.stubs(:valid?).returns(true)
    post :create, params: { :common_parameter => {:name => CommonParameter.first.name} }, session: set_session_user
    assert_redirected_to common_parameters_url
  end

  def test_edit
    get :edit, params: { :id => CommonParameter.first }, session: set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    CommonParameter.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => CommonParameter.first, :common_parameter => {:name => nil} }, session: set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    CommonParameter.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => CommonParameter.first, :common_parameter => {:name => "Reference", :value => "foreman"} }, session: set_session_user
    assert_redirected_to common_parameters_url
  end

  def test_destroy
    common_parameter = CommonParameter.first
    delete :destroy, params: { :id => common_parameter }, session: set_session_user
    assert_redirected_to common_parameters_url
    assert !CommonParameter.exists?(common_parameter.id)
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.default, Role.find_by_name('Viewer')]
  end

  context 'user with viewer rights' do
    def user_with_viewer_rights_should_fail_to_edit_a_common_parameter
      setup_user
      get :edit, params: { :id => CommonParameter.first.id }
      assert @response.status == '403 Forbidden'
    end

    def user_with_viewer_rights_should_succeed_in_viewing_common_parameters
      setup_user
      get :index
      assert_response :success
    end
  end
end
