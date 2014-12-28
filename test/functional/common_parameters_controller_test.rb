require 'test_helper'

class CommonParametersControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    CommonParameter.any_instance.stubs(:valid?).returns(false)
    post :create, {:common_parameter => {:name => nil}}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    CommonParameter.any_instance.stubs(:valid?).returns(true)
    post :create, {:common_parameter => {:name => CommonParameter.first.name}}, set_session_user
    assert_redirected_to common_parameters_url
  end

  def test_edit
    get :edit, {:id => CommonParameter.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    CommonParameter.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => CommonParameter.first, :common_parameter => {:name => nil}}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    CommonParameter.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => CommonParameter.first, :common_parameter => {:name => "Reference", :value => "foreman"}}, set_session_user
    assert_redirected_to common_parameters_url
  end

  def test_destroy
    common_parameter = CommonParameter.first
    delete :destroy, {:id => common_parameter}, set_session_user
    assert_redirected_to common_parameters_url
    assert !CommonParameter.exists?(common_parameter.id)
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  context 'user with viewer rights' do

    def user_with_viewer_rights_should_fail_to_edit_a_common_parameter
      setup_user
      get :edit, {:id => CommonParameter.first.id}
      assert @response.status == '403 Forbidden'
    end

    def user_with_viewer_rights_should_succeed_in_viewing_common_parameters
      setup_user
      get :index
      assert_response :success
    end
  end
end
