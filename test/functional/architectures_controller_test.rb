require 'test_helper'

class ArchitecturesControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_index_json
    get :index, {:format => "json"}, set_session_user
    arches = ActiveSupport::JSON.decode(@response.body)
    assert !arches.empty?
    assert_response :success
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Architecture.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Architecture.any_instance.stubs(:valid?).returns(true)
    post :create, {}, set_session_user
    assert_redirected_to architectures_url
  end

  def test_create_valid_json
    Architecture.any_instance.stubs(:valid?).returns(true)
    post :create, {:format => "json"}, set_session_user
    arch = ActiveSupport::JSON.decode(@response.body)
    assert_response :created
  end

  def test_edit
    get :edit, {:id => Architecture.first.name}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Architecture.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Architecture.first.name}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Architecture.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Architecture.first.name}, set_session_user
    assert_redirected_to architectures_url
  end

  def test_update_valid_json
    Architecture.any_instance.stubs(:valid?).returns(true)
    put :update, {:format=> "json", :id => Architecture.first.name}, set_session_user
    arch = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
  end

  def test_destroy
    architecture = Architecture.first
    architecture.hosts.delete_all
    architecture.hostgroups.delete_all
    delete :destroy, {:id => architecture.name}, set_session_user
    assert_redirected_to architectures_url
    assert !Architecture.exists?(architecture.id)
  end

  def test_destroy_json
    architecture = Architecture.first
    architecture.hosts.delete_all
    architecture.hostgroups.delete_all
    delete :destroy, {:format => "json", :id => architecture.name}, set_session_user
    arch = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    assert !Architecture.exists?(architecture.id)
  end

  def setup_user
     @request.session[:user] = users(:one).id
     users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
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
