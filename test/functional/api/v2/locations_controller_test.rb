require 'test_helper'

class Api::V2::LocationsControllerTest < ActionController::TestCase
  def setup
    @location = taxonomies(:location1)
    @location.organization_ids = [taxonomies(:organization1).id]
    Rabl.configuration.use_controller_name_as_json_root = false
  end

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:locations)
  end

  test "should show location" do
    get :show, { :id => taxonomies(:location1).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
    #assert child nodes are included in response'
    NODES = ["users", "smart_proxies", "subnets", "compute_resources", "media", "config_templates",
             "domains", "environments", "hostgroups", "organizations", "parameters"].sort
    NODES.each do |node|
      assert show_response.keys.include?(node), "'#{node}' child node should be in response but was not"
    end
  end

  test "should not create invalid location" do
    post :create, { :location => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should return an error for no params" do
    post :create
    assert_response :error
  end

  test "should create valid location" do
    post :create, { :location => { :name => "Test Location" } }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should update location on if valid is location" do
    ignore_types = ["Domain", "Hostgroup", "Environment", "User", "Medium", "Subnet", "SmartProxy", "ProvisioningTemplate", "ComputeResource", "Realm"]
    put :update, { :id => @location.to_param, :location => { :name => "New Location", :ignore_types => ignore_types } }
    assert_equal "New Location", Location.find(@location.id).name
    assert_response :success
  end

  test "should not update invalid location" do
    put :update, { :id => Location.first.to_param, :location => { :name => "" } }
    assert_response :unprocessable_entity
  end

  test "should destroy location if hosts do not use it" do
    assert_difference('Location.count', -1) do
      delete :destroy, { :id => taxonomies(:location2).to_param }
    end
    assert_response :success
  end

  test "should NOT destroy location if hosts use it" do
    FactoryGirl.create(:host, :location => taxonomies(:location1))
    assert_difference('Location.count', 0) do
      delete :destroy, { :id => taxonomies(:location1).to_param }
    end
    assert_response :unprocessable_entity
  end

  test "should update *_ids. test for domain_ids" do
    # ignore all but Domain
    @location.ignore_types = ["Hostgroup", "Environment", "User", "Medium", "Subnet", "SmartProxy", "ProvisioningTemplate", "ComputeResource", "Realm"]
    as_admin do
      @location.save(:validate => false)
      assert_difference('@location.domains.count', 2) do
        put :update, { :id => @location.to_param, :location => { :domain_ids => Domain.pluck(:id) } }
      end
    end
    assert_response :success
  end

  test "should get locations for nested object" do
    @location.domain_ids = [domains(:mydomain).id]
    get :index, {:domain_id => domains(:mydomain).to_param }
    assert_response :success
    assert_equal assigns(:locations), [taxonomies(:location1)]
  end

  #####################
  # test config/initializers/rabl_init.rb
  # using Location as class to test rabl extension
  test "root name on index should be results by default" do
    get :index, {}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.is_a?(Hash)
    assert response['results'].is_a?(Array)
    refute response['locations']
  end

  test "root name on index is configured to be controller name" do
    Rabl.configuration.use_controller_name_as_json_root = true
    get :index, {}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.is_a?(Hash)
    refute response['results']
    assert response['locations'].is_a?(Array)
  end

  test "root name on index can be overwritten by param root_name" do
    get :index, {:root_name => "data"}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.is_a?(Hash)
    assert response['data'].is_a?(Array)
    refute response['results']
    refute response['locations']
  end

  test "on index no object_root name for each element in array" do
    get :index, {}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.is_a?(Hash)
    assert response['results'].is_a?(Array)
    assert_equal ['ancestry', 'created_at', 'id', 'name', 'title', 'updated_at'], response['results'][0].keys.sort
  end

  test "object name on show defaults to object class name" do
    obj = taxonomies(:location1)
    get :show, {:id => obj.id}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.is_a?(Hash)
    klass_name = obj.class.name.downcase
    assert "location", klass_name
    assert response.is_a?(Hash)
    assert_equal obj.id, response["id"]
  end

  test "object name on show can be specified" do
    obj = taxonomies(:location1)
    get :show, {:id => obj.id, :root_name => 'row'}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.is_a?(Hash)
    assert response['row'].is_a?(Hash)
    assert_equal obj.id, response['row']["id"]
  end

  test "no object name on show" do
    obj = taxonomies(:location1)
    get :show, {:id => obj.id, :root_name => 'false'}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.is_a?(Hash)
    assert_equal obj.id, response["id"]
  end

  # using Location as class to pagination and search metadata
  # create 26 locations per name per letter A-Z
  def add_locations
    Array('a'..'z').each do |letter|
      Location.create(:name => letter)
    end
  end

  test "should return correct metadata if no params passed" do
    as_admin do
      add_locations
      get :index, { }
    end

    assert_response :success

    response = ActiveSupport::JSON.decode(@response.body)
    expected_metadata = { 'total'    => 28, 'subtotal' => 28,   'page' => 1,
                          'per_page' => 20, 'search'   => nil,
                          'sort' => { 'by' => nil, 'order' => nil } }

    assert_equal expected_metadata, response.except('results')
  end

  test "should return correct metadata if page param is passed" do
    as_admin do
      add_locations
      get :index, {:page => 2 }
    end

    assert_response :success

    response = ActiveSupport::JSON.decode(@response.body)
    expected_metadata = { 'total'    => 28, 'subtotal' => 28,   'page' => 2,
                          'per_page' => 20, 'search'   => nil,
                          'sort' => { 'by' => nil, 'order' => nil } }

    assert_equal expected_metadata, response.except('results')
  end

  test "should return correct metadata if per_page param is passed" do
    as_admin do
      add_locations
      get :index, {:per_page => 10 }
    end

    assert_response :success

    response = ActiveSupport::JSON.decode(@response.body)
    expected_metadata = { 'total'    => 28, 'subtotal' => 28,   'page' => 1,
                          'per_page' => 10, 'search'   => nil,
                          'sort' => { 'by' => nil, 'order' => nil } }

    assert_equal expected_metadata, response.except('results')
  end

  test "should return correct metadata if search param is passed" do
    as_admin do
      add_locations
      get :index, {:search => 'Loc' }
    end

    assert_response :success

    response = ActiveSupport::JSON.decode(@response.body)
    expected_metadata = { 'total'    => 28, 'subtotal' => 2, 'page' => 1,
                          'per_page' => 20, 'search'   => 'Loc',
                          'sort' => { 'by' => nil, 'order' => nil } }

    assert_equal expected_metadata, response.except('results')
  end

  test "should return correct metadata if order param is passed" do
    as_admin do
      add_locations
      get :index, {:order => 'title DESC' }
    end

    assert_response :success

    response = ActiveSupport::JSON.decode(@response.body)
    expected_metadata = { 'total'    => 28, 'subtotal' => 28, 'page' => 1,
                          'per_page' => 20, 'search'   => nil,
                          'sort' => { 'by' => 'title', 'order' => 'DESC' } }

    assert_equal expected_metadata, response.except('results')
  end
end
