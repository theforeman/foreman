require 'test_helper'

class Api::V1::DomainsControllerTest < ActionController::TestCase
  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:domains)
  end

  test "should not create invalid domain" do
    as_user :admin do
      post :create, {:domain => {:fullname => ""}}
    end
    assert_response :unprocessable_entity
  end

  test "should create valid domain" do
    as_user :admin do
      post :create, {:domain => {:name => "domain.net"}}
    end
    domain = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
  end

  test "should not update invalid domain" do
    as_user :admin do
      put :update, {:id => Domain.first.to_param, :domain => {:name => ""}}
    end
    assert_response :unprocessable_entity
  end

  test "should update valid domain" do
    as_user :admin do
      put :update, {:id => Domain.first.to_param, :domain => {:name => "domain.new"}}
    end
    assert_equal "domain.new", Domain.first.name
    assert_response :success
  end

  test "should destroy domain" do
    domain = Domain.first
    domain.hosts.clear
    domain.hostgroups.clear
    domain.subnets.clear
    as_user :admin do
      delete :destroy, {:id => domain.to_param}
    end
    domain = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    assert !Domain.exists?(:name => domain['id'])
  end
end
