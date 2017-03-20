require 'test_helper'

class Api::V1::DomainsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:domains)
  end

  test "should show domain" do
    get :show, params: { :id => Domain.first.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create valid domain" do
    post :create, params: { :domain => { :name => "domain.net" } }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should not create invalid domain" do
    post :create, params: { :domain => { :fullname => "" } }
    assert_response :unprocessable_entity
  end

  test "should update valid domain" do
    put :update, params: { :id => Domain.unscoped.first.to_param, :domain => { :name => "domain.new" } }
    assert_equal "domain.new", Domain.unscoped.first.name
    assert_response :success
  end

  test "should not update invalid domain" do
    put :update, params: { :id => Domain.first.to_param, :domain => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy domain" do
    domain = Domain.first
    domain.hosts.clear
    domain.hostgroups.clear
    domain.subnets.clear
    delete :destroy, params: { :id => domain.to_param }
    domain = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    assert !Domain.exists?(:name => domain['id'])
  end
end
