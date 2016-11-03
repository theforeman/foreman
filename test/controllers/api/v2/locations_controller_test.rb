require 'test_helper'

class Api::V2::LocationsControllerTest < ActionController::TestCase
  def setup
    @location = taxonomies(:location1)
    @location.organization_ids = [taxonomies(:organization1).id]
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
             "provisioning_templates", "domains", "ptables", "realms", "environments", "hostgroups",
             "organizations", "parameters"].sort
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
    assert_response :unprocessable_entity
  end

  test "should create valid location" do
    post :create, { :location => { :name => "Test Location" } }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create location with parent" do
    parent_id = Location.first.id
    post :create, { :location => { :name => "Test Location", :parent_id =>  parent_id } }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
    assert_equal parent_id, show_response['parent_id']
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
    assert_difference('Location.unscoped.count', -1) do
      delete :destroy, { :id => taxonomies(:location2).to_param }
    end
    assert_response :success
  end

  test "should delete taxonomies if it's one of user's" do
    loc1 = FactoryGirl.create(:location)
    loc2 = FactoryGirl.create(:location)
    user = FactoryGirl.create(:user)
    user.locations = [ loc1 ]
    filter = FactoryGirl.create(:filter, :permissions => [ Permission.find_by_name(:destroy_locations) ])
    user.roles << filter.role
    as_user user do
      delete :destroy, { :id => loc2 }
      assert_response :not_found
    end
  end

  test "should dissociate hosts from the destroyed location" do
    host = FactoryGirl.create(:host, :location => taxonomies(:location1))
    assert_difference('Location.unscoped.count', -1) do
      delete :destroy, { :id => taxonomies(:location1).to_param }
    end
    assert_response :success
    assert_nil Host::Managed.find(host.id).location
  end

  test "should update *_ids. test for domain_ids" do
    # ignore all but Domain
    @location.ignore_types = ["Hostgroup", "Environment", "User", "Medium",
                              "Subnet", "SmartProxy", "ProvisioningTemplate",
                              "ComputeResource", "Realm"]
    as_admin do
      @location.save(:validate => false)
      assert_difference('@location.domains.count', 2) do
        put :update, {
          :id => @location.to_param,
          :location => { :domain_ids => Domain.unscoped.pluck(:id) }
        }
        User.current = users(:admin)
        # as_admin gets invalidated after the call, so we need to restore it
        # in order to make the call to @location.domains.count  in the right
        # context
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

  context "use_controller_name_as_json_root is enabled" do
    setup do
      Rabl.configuration.use_controller_name_as_json_root = true
    end

    teardown do
      Rabl.configuration.use_controller_name_as_json_root = false
    end

    test "root name on index is configured to be controller name" do
      get :index, {}
      response = ActiveSupport::JSON.decode(@response.body)
      assert response.is_a?(Hash)
      refute response['results']
      assert response['locations'].is_a?(Array)
    end
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
    assert_equal ['ancestry', 'created_at', 'description', 'id', 'name', 'parent_id', 'parent_name', 'title', 'updated_at'], response['results'][0].keys.sort
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
    expected_metadata = { 'total'    => 28, 'subtotal' => 28, 'page' => 1,
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
    expected_metadata = { 'total'    => 28, 'subtotal' => 28, 'page' => 2,
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
    expected_metadata = { 'total'    => 28, 'subtotal' => 28, 'page' => 1,
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

  test "user without view_params permission can't see location parameters" do
    location_with_parameter = FactoryGirl.create(:location, :with_parameter)
    setup_user "view", "locations"
    get :show, {:id => location_with_parameter.to_param, :format => 'json'}
    assert_empty JSON.parse(response.body)['parameters']
  end

  test "user with view_params permission can see location parameters" do
    location_with_parameter = FactoryGirl.create(:location, :with_parameter)
    location_with_parameter.users << users(:one)
    setup_user "view", "locations"
    setup_user "view", "params"
    get :show, {:id => location_with_parameter.to_param, :format => 'json'}
    assert_not_empty JSON.parse(response.body)['parameters']
  end

  context 'hidden parameters' do
    test "should show a location parameter as hidden unless show_hidden_parameters is true" do
      location = FactoryGirl.create(:location)
      location.location_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, { :id => location.id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal '*****', show_response['parameters'].first['value']
    end

    test "should show a location parameter as unhidden when show_hidden_parameters is true" do
      location = FactoryGirl.create(:location)
      location.location_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, { :id => location.id, :show_hidden_parameters => 'true' }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 'bar', show_response['parameters'].first['value']
    end
  end

  test "should update existing location parameters" do
    location = FactoryGirl.create(:location)
    param_params = { :name => "foo", :value => "bar" }
    location.location_parameters.create!(param_params)
    put :update, { :id => location.id, :location => { :location_parameters_attributes => [{ :name => param_params[:name], :value => "new_value" }] } }
    assert_response :success
    assert param_params[:name], location.parameters[param_params[:name]]
  end

  test "should delete existing location parameters" do
    location = FactoryGirl.create(:location)
    param_1 = { :name => "foo", :value => "bar" }
    param_2 = { :name => "boo", :value => "test" }
    location.location_parameters.create!([param_1, param_2])
    put :update, { :id => location.id, :location => { :location_parameters_attributes => [{ :name => param_1[:name], :value => "new_value" }] } }
    assert_response :success
    assert_equal 1, location.reload.location_parameters.count
  end
end
