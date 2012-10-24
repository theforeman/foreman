require 'test_helper'

class SubnetsControllerTest < ActionController::TestCase
  def test_index
    get :index, {} , set_session_user
    assert_template 'index'
  end

  def test_index_json
    get :index, {:format => "json"} , set_session_user
    subnets = ActiveSupport::JSON.decode(@response.body)
    assert subnets.is_a?(Array)
    assert_response :success
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Subnet.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Subnet.any_instance.stubs(:valid?).returns(true)
    post :create, {:subnet => {:network => "192.168.0.1", :mask => "255.255.255.0"}}, set_session_user
    assert_redirected_to subnets_url
  end

  def test_create_valid_json
    Subnet.any_instance.stubs(:valid?).returns(true)
    post :create, {:format => "json", :subnet => {:network => "192.168.0.1", :mask => "255.255.255.0"}}, set_session_user
    subnet = ActiveSupport::JSON.decode(@response.body)
    assert_response :created
  end

  def test_edit
    get :edit, {:id => Subnet.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Subnet.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Subnet.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Subnet.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Subnet.first}, set_session_user
    assert_redirected_to subnets_url
  end

  def test_update_valid_json
    Subnet.any_instance.stubs(:valid?).returns(true)
    put :update, {:format => "json", :id => Subnet.first}, set_session_user
    subnet = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
  end

  def test_should_not_destroy_if_used_by_hosts
    subnet = subnets(:one)
    delete :destroy, {:id => subnet}, set_session_user
    assert_redirected_to subnets_url
    assert Subnet.exists?(subnet.id)
  end

  def test_destroy
    subnet = Subnet.first
    subnet.hosts.clear
    delete :destroy, {:id => subnet}, set_session_user
    assert_redirected_to subnets_url
    assert !Subnet.exists?(subnet.id)
  end

  def test_destroy_json
    subnet = Subnet.first
    subnet.hosts.clear
    delete :destroy, {:format => "json", :id => subnet}, set_session_user
    subnet = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    assert !Subnet.exists?(:id => subnet['id'])
  end
end
