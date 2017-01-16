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

  test "should create valid domain" do
    post :create, { :domain => { :name => "domain.net" } }
    assert_response :created
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should not create invalid domain" do
    post :create, { :domain => { :fullname => "" } }
    assert_response :unprocessable_entity
  end

  test "should not create invalid dns_id" do
    # Currently Rails 4.2 does not support foreign key constraint with sqlite3
    # (See https://github.com/rails/rails/pull/22236)
    # Skipping this test until resolved
    skip if ActiveRecord::Base.connection_config[:adapter].eql?"sqlite3"
    invalid_proxy_id = SmartProxy.last.id + 100
    post :create, { :domain => { :name => "doma.in", :dns_id => invalid_proxy_id } }
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_includes(show_response["error"]["full_messages"], "Dns Invalid smart-proxy id")
    assert_response :unprocessable_entity
  end

  test "should update valid domain" do
    put :update, { :id => Domain.first.to_param, :domain => { :name => "domain.new" } }
    assert_equal "domain.new", Domain.unscoped.first.name
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
    refute Domain.find_by_id(domain['id'])
  end

  #test that taxonomy scope works for api for domains
  def setup
    taxonomies(:location1).domain_ids = [domains(:mydomain).id, domains(:yourdomain).id]
    taxonomies(:organization1).domain_ids = [domains(:mydomain).id]
  end

  test "should get domains for location only" do
    get :index, {:location_id => taxonomies(:location1).id }
    assert_response :success
    assert_equal taxonomies(:location1).domains.length, assigns(:domains).length
    assert_equal assigns(:domains), taxonomies(:location1).domains
  end

  test "should get domains for organization only" do
    get :index, {:organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal taxonomies(:organization1).domains.length, assigns(:domains).length
    assert_equal taxonomies(:organization1).domains, assigns(:domains)
  end

  test "should get domains for both location and organization" do
    get :index, {:location_id => taxonomies(:location1).id, :organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal 1, assigns(:domains).length
    assert_equal assigns(:domains), [domains(:mydomain)]
  end

  test "should show domain with correct child nodes including location and organization" do
    get :show, { :id => domains(:mydomain).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
    #assert child nodes are included in response'
    NODES = ["locations", "organizations", "parameters", "subnets"]
    NODES.sort.each do |node|
      assert show_response.keys.include?(node), "'#{node}' child node should be in response but was not"
    end
  end

  test "user without view_params permission can't see domain parameters" do
    setup_user "view", "domains"
    domain_with_parameter = FactoryGirl.create(:domain, :with_parameter)
    get :show, {:id => domain_with_parameter.to_param, :format => 'json'}
    assert_empty JSON.parse(response.body)['parameters']
  end

  test "user with view_params permission can see domain parameters" do
    setup_user "view", "domains"
    setup_user "view", "params"
    domain_with_parameter = FactoryGirl.create(:domain, :with_parameter)
    get :show, {:id => domain_with_parameter.to_param, :format => 'json'}
    assert_not_empty JSON.parse(response.body)['parameters']
  end
end
