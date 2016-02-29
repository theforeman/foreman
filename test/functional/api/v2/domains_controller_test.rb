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

  context "token based authentication" do

    setup do
      @request.env['HTTP_AUTHORIZATION'] = nil
      @access_token = get_access_token  #get_access_token is method in test_helper.rb
    end

    teardown do
      user = users(:apiadmin)
      login = user.login
      password = 'secret'
      @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(login, password)
      @access_token = nil
    end

    test "get index based on access_token in URL" do
      get :index, { :access_token => @access_token }
      assert_response :success
      refute_nil assigns(:domains)
    end

    test "get index based on access_token in HEADER" do
      @request.env['HTTP_AUTHORIZATION'] = "Bearer #{@access_token}"
      get :index, { :access_token => @access_token }
      assert_response :success
      refute_nil assigns(:domains)
    end
  end

end
