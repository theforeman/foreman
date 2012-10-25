require 'test_helper'

class Api::V1::SubnetsControllerTest < ActionController::TestCase
  def test_index
    as_admin { get :index }
    subnets = ActiveSupport::JSON.decode(@response.body)
    assert subnets.is_a?(Array)
    assert_response :success
  end

  def test_create_invalid
    as_admin { post :create }
    assert_response :unprocessable_entity
  end

  def test_create_valid
    Subnet.any_instance.stubs(:valid?).returns(true)
    as_admin { post :create, {:subnet => {:network => "192.168.0.1", :mask => "255.255.255.0"}} }
    subnet = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
  end

  def test_update_invalid
    as_admin { put :update, {:id => Subnet.first.id, :subnet => {:mask => ''}} }
    assert_response :unprocessable_entity
  end

  def test_update_valid
    as_admin { put :update, {:id => Subnet.first.id, :subnet => {:name => 'updated'} } }
    subnet = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    assert subnet['subnet']['name'] == 'updated'
  end

  def test_should_not_destroy_if_used_by_hosts
    subnet = Subnet.first
    as_admin {delete :destroy, {:id => subnet.id} }
    assert Subnet.exists?(subnet.id)
  end

  def test_destroy_json
    subnet = Subnet.first
    subnet.hosts.clear
    as_admin { delete :destroy, {:id => subnet.id} }
    ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    assert !Subnet.exists?(:id => subnet.id)
  end
end
