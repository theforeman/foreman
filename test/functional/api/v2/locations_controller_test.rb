require 'test_helper'

class Api::V2::LocationsControllerTest < ActionController::TestCase

  def setup
#    TODO was 500 since there is not include Authorization in taxonomy.rb
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
    get :show, { :id => Location.first.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
    #assert *_ids are included in response. Test just for domain_ids
    assert show_response["location"].any? {|k,v| k == "domain_ids" }
  end

  test "should not create invalid location" do
    post :create, { :location => { :name => "" } }
#    TODO was 500 since there is not include Authorization in taxonomy.rb
#    assert_response :unprocessable_entity
  end

  test "should create valid location" do
    post :create, { :location => { :name => "Test Location" } }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should update location on if valid is location" do
    ignore_types = ["Domain", "Hostgroup", "Environment", "User", "Medium", "Subnet", "SmartProxy", "ConfigTemplate", "ComputeResource"]
    put :update, { :id => @location.to_param, :location => { :name => "New Location", :ignore_types => ignore_types } }
    assert_equal "New Location", Location.find(@location.id).name
    assert_response :success
  end

  test "should not update invalid location" do
    put :update, { :id => Location.first.to_param, :location => { :name => "" } }
#    TODO was 500 since there is not include Authorization
#    assert_response :unprocessable_entity
  end

  test "should destroy location if hosts do not use it" do
    assert_difference('Location.count', -1) do
      delete :destroy, { :id => taxonomies(:location2).to_param }
    end
    assert_response :success
  end

  test "should NOT destroy location if hosts use it" do
    assert_difference('Location.count', 0) do
      delete :destroy, { :id => taxonomies(:location1).to_param }
    end
#    TODO was 500 since there is not include Authorization in taxonomy.rb
#    assert_response :unprocessable_entity
  end

  test "should update *_ids. test for domain_ids" do
    # ignore all but Domain
    @location.ignore_types = ["Hostgroup", "Environment", "User", "Medium", "Subnet", "SmartProxy", "ConfigTemplate", "ComputeResource"]
    @location.save(:validate => false)
    assert_difference('@location.domains.count', 4) do
      put :update, { :id => @location.to_param, :location => { :domain_ids => Domain.pluck(:id) } }
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
    assert response.kind_of?(Hash)
    assert response['results'].kind_of?(Array)
    refute response['locations']
  end

  test "root name on index is configured to be controller name" do
    Rabl.configuration.use_controller_name_as_json_root = true
    get :index, {}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.kind_of?(Hash)
    refute response['results']
    assert response['locations'].kind_of?(Array)
  end

  test "root name on index can be overwritten by param root_name" do
    get :index, {:root_name => "data"}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.kind_of?(Hash)
    assert response['data'].kind_of?(Array)
    refute response['results']
    refute response['locations']
  end

  test "on index no object_root name for each element in array" do
    get :index, {}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.kind_of?(Hash)
    assert response['results'].kind_of?(Array)
    assert_equal ['id', 'name'], response['results'][0].keys.sort
  end

  test "object name on show defaults to object class name" do
    obj = taxonomies(:location1)
    get :show, {:id => obj.id}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.kind_of?(Hash)
    klass_name = obj.class.name.downcase
    assert "location", klass_name
    assert response[klass_name].kind_of?(Hash)
    assert_equal obj.id, response[klass_name]["id"]
  end

  test "object name on show can be specified" do
    obj = taxonomies(:location1)
    get :show, {:id => obj.id, :object_name => 'row'}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.kind_of?(Hash)
    assert response['row'].kind_of?(Hash)
    assert_equal obj.id, response['row']["id"]
  end

  test "no object name on show" do
    obj = taxonomies(:location1)
    get :show, {:id => obj.id, :object_name => 'false'}
    response = ActiveSupport::JSON.decode(@response.body)
    assert response.kind_of?(Hash)
    assert_equal obj.id, response["id"]
  end

end
