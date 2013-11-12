require 'test_helper'

class Api::V2::DomainsControllerTest < ActionController::TestCase


  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:domains)
  end

  test "should show domain" do
    get :show, { :id => Domain.first.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should not create invalid domain" do
    post :create, { :domain => { :fullname => "" } }
    assert_response :unprocessable_entity
  end

  test "should create valid domain" do
    post :create, { :domain => { :name => "domain.net" } }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should update valid domain" do
    put :update, { :id => Domain.first.to_param, :domain => { :name => "domain.new" } }
    assert_equal "domain.new", Domain.first.name
    assert_response :success
  end

  test "should not update invalid domain" do
    put :update, { :id => Domain.first.to_param, :domain => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy domain" do
    domain = Domain.first
    domain.hosts.clear
    domain.hostgroups.clear
    domain.subnets.clear
    delete :destroy, { :id => domain.to_param }
    domain = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    assert !Domain.exists?(:name => domain['id'])
  end

  #test that taxonomy scope works for api for domains
  def setup
    taxonomies(:location1).domain_ids = [domains(:mydomain).id, domains(:yourdomain).id]
    taxonomies(:organization1).domain_ids = [domains(:mydomain).id]
  end

  test "should get domains for location only" do
    get :index, {:location_id => taxonomies(:location1).id }
    assert_response :success
    assert_equal 2, assigns(:domains).length
    assert_equal assigns(:domains), [domains(:mydomain), domains(:yourdomain)]
  end

  test "should get domains for organization only" do
    get :index, {:organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal 1, assigns(:domains).length
    assert_equal assigns(:domains), [domains(:mydomain)]
  end

  test "should get domains for both location and organization" do
    get :index, {:location_id => taxonomies(:location1).id, :organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal 1, assigns(:domains).length
    assert_equal assigns(:domains), [domains(:mydomain)]
  end

end
