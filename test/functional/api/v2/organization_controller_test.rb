require 'test_helper'

class Api::V2::OrganizationsControllerTest < ActionController::TestCase
  def setup
    @organization = taxonomies(:organization1)
    @organization.location_ids = [taxonomies(:location1).id]
    Rabl.configuration.use_controller_name_as_json_root = false
  end

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:organizations)
  end

  test "should show organization" do
    get :show, { :id => taxonomies(:organization1).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
    #assert child nodes are included in response'
    NODES = ["users", "smart_proxies", "subnets", "compute_resources", "media", "config_templates",
             "domains", "environments", "hostgroups", "locations", "parameters"].sort
    NODES.each do |node|
      assert show_response.keys.include?(node), "'#{node}' child node should be in response but was not"
    end
  end

  test "should not create invalid organization" do
    post :create, { :organization => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should return an error for no params" do
    post :create
    assert_response :unprocessable_entity
  end

  test "should create valid organization" do
    post :create, { :organization => { :name => "Test Organization" } }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should update organization on if valid is organization" do
    ignore_types = ["Domain", "Hostgroup", "Environment", "User", "Medium", "Subnet", "SmartProxy", "ConfigTemplate", "ComputeResource", "Realm"]
    put :update, { :id => @organization.to_param, :organization => { :name => "New Organization", :ignore_types => ignore_types } }
    assert_equal "New Organization", Organization.find(@organization.id).name
    assert_response :success
  end

  test "should not update invalid organization" do
    put :update, { :id => Organization.first.to_param, :organization => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy organization if hosts do not use it" do
    assert_difference('Organization.count', -1) do
      delete :destroy, { :id => taxonomies(:organization2).to_param }
    end
    assert_response :success
  end

  test "should NOT destroy organization if hosts use it" do
    FactoryGirl.create(:host, :organization => taxonomies(:organization1))
    assert_difference('Organization.count', 0) do
      delete :destroy, { :id => taxonomies(:organization1).to_param }
    end
    assert_response :unprocessable_entity
  end

  test "should update *_ids. test for domain_ids" do
    # ignore all but Domain
    @organization.ignore_types = ["Hostgroup", "Environment", "User", "Medium", "Subnet", "SmartProxy", "ConfigTemplate", "ComputeResource", "Realm"]
    as_admin do
      @organization.save(:validate => false)
      assert_difference('@organization.domains.count', 3) do
        put :update, { :id => @organization.to_param, :organization => { :domain_ids => Domain.pluck(:id) } }
      end
    end
    assert_response :success
  end

  test "should get organizations for nested object" do
    @organization.domain_ids = [domains(:mydomain).id]
    get :index, {:domain_id => domains(:mydomain).to_param }
    assert_response :success
    assert_equal assigns(:organizations), [taxonomies(:organization1)]
  end

  #####################
  # test config/initializers/rabl_init.rb
  # using Organization as class to test rabl extension
  test "root name on index should be results by default" do
    get :index, {}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.is_a?(Hash)
    assert response['results'].is_a?(Array)
    refute response['organizations']
  end

  test "root name on index is configured to be controller name" do
    Rabl.configuration.use_controller_name_as_json_root = true
    get :index, {}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.is_a?(Hash)
    refute response['results']
    assert response['organizations'].is_a?(Array)
  end

  test "root name on index can be overwritten by param root_name" do
    get :index, {:root_name => "data"}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.is_a?(Hash)
    assert response['data'].is_a?(Array)
    refute response['results']
    refute response['organizations']
  end

  test "on index no object_root name for each element in array" do
    get :index, {}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.is_a?(Hash)
    assert response['results'].is_a?(Array)
    assert_equal ['created_at', 'id', 'name', 'title', 'updated_at'], response['results'][0].keys.sort
  end

  test "object name on show defaults to object class name" do
    obj = taxonomies(:organization1)
    get :show, {:id => obj.id}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.is_a?(Hash)
    klass_name = obj.class.name.downcase
    assert "organization", klass_name
    assert response.is_a?(Hash)
    assert_equal obj.id, response["id"]
  end

  test "object name on show can be specified" do
    obj = taxonomies(:organization1)
    get :show, {:id => obj.id, :root_name => 'row'}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.is_a?(Hash)
    assert response['row'].is_a?(Hash)
    assert_equal obj.id, response['row']["id"]
  end

  test "no object name on show" do
    obj = taxonomies(:organization1)
    get :show, {:id => obj.id, :root_name => 'false'}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.is_a?(Hash)
    assert_equal obj.id, response["id"]
  end

  # using Organization as class to pagination and search metadata
  # create 26 organizations per name per letter A-Z
  def add_organizations
    Array('a'..'z').each do |letter|
      Organization.create(:name => letter)
    end
  end

  test "should return correct metadata if no params passed" do
    as_admin do
      add_organizations
      get :index, { }
    end

    assert_response :success

    response = ActiveSupport::JSON.decode(@response.body)
    expected_metadata = { 'total'    => 29, 'subtotal' => 29,   'page' => 1,
                          'per_page' => 20, 'search'   => nil,
                          'sort' => { 'by' => nil, 'order' => nil } }

    assert_equal expected_metadata, response.except('results')
  end

  test "should return correct metadata if page param is passed" do
    as_admin do
      add_organizations
      get :index, {:page => 2 }
    end

    assert_response :success

    response = ActiveSupport::JSON.decode(@response.body)
    expected_metadata = { 'total'    => 29, 'subtotal' => 29,   'page' => 2,
                          'per_page' => 20, 'search'   => nil,
                          'sort' => { 'by' => nil, 'order' => nil } }

    assert_equal expected_metadata, response.except('results')
  end

  test "should return correct metadata if per_page param is passed" do
    as_admin do
      add_organizations
      get :index, {:per_page => 10 }
    end

    assert_response :success

    response = ActiveSupport::JSON.decode(@response.body)
    expected_metadata = { 'total'    => 29, 'subtotal' => 29,   'page' => 1,
                          'per_page' => 10, 'search'   => nil,
                          'sort' => { 'by' => nil, 'order' => nil } }

    assert_equal expected_metadata, response.except('results')
  end

  test "should return correct metadata if search param is passed" do
    as_admin do
      add_organizations
      get :index, {:search => 'Org' }
    end

    assert_response :success

    response = ActiveSupport::JSON.decode(@response.body)
    expected_metadata = { 'total'    => 29, 'subtotal' => 3, 'page' => 1,
                          'per_page' => 20, 'search'   => 'Loc',
                          'sort' => { 'by' => nil, 'order' => nil } }

    assert_equal expected_metadata, response.except('results')
  end

  test "should return correct metadata if order param is passed" do
    as_admin do
      add_organizations
      get :index, {:order => 'title DESC' }
    end

    assert_response :success

    response = ActiveSupport::JSON.decode(@response.body)
    expected_metadata = { 'total'    => 29, 'subtotal' => 29, 'page' => 1,
                          'per_page' => 20, 'search'   => nil,
                          'sort' => { 'by' => 'title', 'order' => 'DESC' } }
    assert_equal expected_metadata, response.except('results')
  end
end
