require 'test_helper'

class Api::V2::DomainsControllerTest < ActionController::TestCase
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
    assert_response :created
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should not create invalid domain" do
    post :create, params: { :domain => { :fullname => "" } }
    assert_response :unprocessable_entity
  end

  test "should not create invalid dns_id" do
    invalid_proxy_id = SmartProxy.last.id + 100
    post :create, params: { :domain => { :name => "doma.in", :dns_id => invalid_proxy_id } }
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_includes(show_response["error"]["full_messages"], "Dns Invalid smart-proxy id")
    assert_response :unprocessable_entity
  end

  test "should update valid domain" do
    put :update, params: { :id => Domain.first.to_param, :domain => { :name => "domain.new" } }
    assert_equal "domain.new", Domain.unscoped.first.name
    assert_response :success
  end

  test "should not update invalid domain" do
    put :update, params: { :id => Domain.first.to_param, :domain => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should not create invalid dns_id" do
    invalid_proxy_id = -1
    post :update, params: { :id => Domain.first.to_param, :domain => { :name => "domain.new", :dns_id => invalid_proxy_id } }
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_includes(show_response["error"]["full_messages"], "Dns Invalid smart-proxy id")
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
    refute Domain.find_by_id(domain['id'])
  end

  #test that taxonomy scope works for api for domains
  def setup
    taxonomies(:location1).domain_ids = [domains(:mydomain).id, domains(:yourdomain).id]
    taxonomies(:organization1).domain_ids = [domains(:mydomain).id]
  end

  test "should get domains for location only" do
    get :index, params: { :location_id => taxonomies(:location1).id }
    assert_response :success
    assert_equal taxonomies(:location1).domains.length, assigns(:domains).length
    assert_equal assigns(:domains), taxonomies(:location1).domains
  end

  test "should get domains for organization only" do
    get :index, params: { :organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal taxonomies(:organization1).domains.length, assigns(:domains).length
    assert_equal taxonomies(:organization1).domains, assigns(:domains)
  end

  test "should get domains for both location and organization" do
    get :index, params: { :location_id => taxonomies(:location1).id, :organization_id => taxonomies(:organization1).id }
    assert_response :success
    assert_equal 1, assigns(:domains).length
    assert_equal assigns(:domains), [domains(:mydomain)]
  end

  test "should show domain with correct child nodes including location and organization" do
    get :show, params: { :id => domains(:mydomain).to_param }
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
    domain_with_parameter = FactoryBot.create(:domain, :with_parameter)
    setup_user "view", "domains"
    get :show, params: { :id => domain_with_parameter.to_param, :format => 'json' }
    assert_empty JSON.parse(response.body)['parameters']
  end

  test "user with view_params permission can see domain parameters" do
    domain_with_parameter = FactoryBot.create(:domain, :with_parameter)
    setup_user "view", "domains"
    setup_user "view", "params"
    get :show, params: { :id => domain_with_parameter.to_param, :format => 'json' }
    assert_not_empty JSON.parse(response.body)['parameters']
  end

  context 'hidden parameters' do
    test "should show a domain parameter as hidden unless show_hidden_parameters is true" do
      domain = FactoryBot.create(:domain)
      domain.domain_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, params: { :id => domain.id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal '*****', show_response['parameters'].first['value']
    end

    test "should show a domain parameter as unhidden when show_hidden_parameters is true" do
      domain = FactoryBot.create(:domain)
      domain.domain_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, params: { :id => domain.id, :show_hidden_parameters => 'true' }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 'bar', show_response['parameters'].first['value']
    end
  end

  test "should update existing domain parameters" do
    domain = FactoryBot.create(:domain)
    param_params = { :name => "foo", :value => "bar" }
    domain.domain_parameters.create!(param_params)
    put :update, params: { :id => domain.id, :domain => { :domain_parameters_attributes => [{ :name => param_params[:name], :value => "new_value" }] } }
    assert_response :success
    assert param_params[:name], domain.parameters.first.name
  end

  test "should delete existing domain parameters" do
    domain = FactoryBot.create(:domain)
    param_1 = { :name => "foo", :value => "bar" }
    param_2 = { :name => "boo", :value => "test" }
    domain.domain_parameters.create!([param_1, param_2])
    put :update, params: { :id => domain.id, :domain => { :domain_parameters_attributes => [{ :name => param_1[:name], :value => "new_value" }] } }
    assert_response :success
    assert_equal 1, domain.parameters.count
  end

  test "should get domains for searched location only" do
    taxonomies(:location2).domain_ids = [domains(:unuseddomain).id]
    get :index, params: { :search => "location_id=#{taxonomies(:location2).id}" }
    assert_response :success
    assert_equal taxonomies(:location2).domains.length, assigns(:domains).length
    assert_equal assigns(:domains), taxonomies(:location2).domains
  end

  test "should get domains when searching with organization_id" do
    domain = FactoryBot.create(:domain)
    org = FactoryBot.create(:organization)
    org.domain_ids = [domain.id]
    get :index, params: {:search => domain.name, :organization_id => org.id }
    assert_response :success
    assert_equal org.domains.length, assigns(:domains).length
    assert_equal assigns(:domains), org.domains
  end
end
