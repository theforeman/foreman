require 'test_helper'

class ArchitecturesControllerTest < ActionController::TestCase
  setup do
    @model = Architecture.first
  end

  basic_index_test
  basic_new_test
  basic_edit_test

  def test_new_submit_button_id
    get :new, {}, set_session_user
    assert_select "[data-id='aid_create_architecture']"
  end

  def test_new_cancel_button_id
    get :new, {}, set_session_user
    assert_select "[data-id='aid_architectures']"
  end

  def test_create_invalid
    Architecture.any_instance.stubs(:valid?).returns(false)
    post :create, {:architecture => {:name => nil}}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Architecture.any_instance.stubs(:valid?).returns(true)
    post :create, {:architecture => {:name => 'i386'}}, set_session_user
    assert_redirected_to architectures_url
  end

  def test_edit_submit_button_id
    get :edit, {:id => Architecture.first}, set_session_user
    assert_select "[data-id='aid_update_architecture']"
  end

  def test_update_invalid
    Architecture.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Architecture.first.to_param, :architecture => {:name => "3243"}}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Architecture.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Architecture.first.to_param, :architecture => {:name => Architecture.first.name}}, set_session_user
    assert_redirected_to architectures_url
  end

  def test_destroy
    architecture = Architecture.first
    architecture.hosts.delete_all
    architecture.hostgroups.delete_all
    delete :destroy, {:id => architecture}, set_session_user
    assert_redirected_to architectures_url
    assert !Architecture.exists?(architecture.id)
  end

  test "403 response contains missing permissions" do
    setup_user
    get :edit, { :id => Architecture.first.id }, {:user => users(:one).id, :expires_at => 5.minutes.from_now}
    assert_response :forbidden
    assert_includes @response.body, 'edit_architectures'
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.default, Role.find_by_name('Viewer')]
  end

  def user_with_viewer_rights_should_fail_to_edit_an_architecture
    setup_user
    get :edit, {:id => Architecture.first.id}
    assert @response.status == '403 Forbidden'
  end

  def user_with_viewer_rights_should_succeed_in_viewing_architectures
    setup_user
    get :index
    assert_response :success
  end
end
