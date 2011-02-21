require 'test_helper'

class HypervisorsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_index_json
    get :index, {:format => "json"}, set_session_user
    hypervisors = ActiveSupport::JSON.decode(@response.body)
    assert hypervisors.is_a?(Array)
    assert_response :success
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Hypervisor.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Hypervisor.any_instance.stubs(:valid?).returns(true)
    post :create, {}, set_session_user
    assert_redirected_to hypervisors_url
  end

  def test_create_valid_json
    Hypervisor.any_instance.stubs(:valid?).returns(true)
    post :create, {:format => "json"}, set_session_user
    hypervisor = ActiveSupport::JSON.decode(@response.body)
    assert_response :created
  end

  def test_edit
    get :edit, {:id => Hypervisor.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Hypervisor.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Hypervisor.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Hypervisor.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Hypervisor.first}, set_session_user
    assert_redirected_to hypervisors_url
  end

  def test_update_valid_json
    Hypervisor.any_instance.stubs(:valid?).returns(true)
    put :update, {:format => "json", :id => Hypervisor.first}, set_session_user
    hypervisor = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
  end

  def test_destroy
    hypervisor = Hypervisor.first
    delete :destroy, {:id => hypervisor}, set_session_user
    assert_redirected_to hypervisors_url
    assert !Hypervisor.exists?(hypervisor.id)
  end

  def test_destroy_json
    hypervisor = Hypervisor.first
    delete :destroy, {:format => "json", :id => hypervisor}, set_session_user
    hypervisor = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    assert !Hypervisor.exists?(hypervisor['id'])
  end
end
