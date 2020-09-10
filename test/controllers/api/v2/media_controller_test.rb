require 'test_helper'

class Api::V2::MediaControllerTest < ActionController::TestCase
  setup do
    @new_medium = {
      :name => "new medium",
      :path => "http://www.newmedium.com/",
      :organization_ids => [Organization.first.id],
    }
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:media)
    medium = ActiveSupport::JSON.decode(@response.body)
    assert !medium.empty?
  end

  test "should show medium" do
    get :show, params: { :id => media(:one).to_param }
    assert_not_nil assigns(:medium)
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create medium with valid name" do
    assert_difference('Medium.unscoped.count') do
      post :create, params: { :medium => @new_medium }
    end
    assert_response :created
    assert_equal @new_medium[:name], JSON.parse(@response.body)["name"], "Can't create media with valid name #{@new_medium[:name]}"
  end

  test "should create medium with os family" do
    os_family = Operatingsystem.families.sample
    medium_os_family = @new_medium.clone.update(:os_family => os_family)
    post :create, params: { :medium => medium_os_family }
    assert_response :created
    assert_equal os_family, JSON.parse(@response.body)["os_family"], "Can't create media with valid os family #{os_family}"
  end

  test "should create medium with location" do
    location = Location.first
    medium_location = @new_medium.clone.update(:location_ids => [location.id])
    post :create, params: { :medium => medium_location }
    assert_response :created
    assert_equal location.name, JSON.parse(@response.body)["locations"][0]["name"], "Can't create media with valid location #{location}"
  end

  test "should create medium with os" do
    os = Operatingsystem.first
    medium_os = @new_medium.clone.update(:operatingsystem_ids => [os.id])
    post :create, params: { :medium => medium_os }
    assert_response :created
    assert_equal os.name, JSON.parse(@response.body)["operatingsystems"][0]["name"], "Can't create media with valid os #{os}"
  end

  test "should not create with invalid name" do
    name = ""
    media_invalid_name = @new_medium.clone.update(:name => name)
    post :create, params: { :medium => media_invalid_name }
    assert_response :unprocessable_entity, "Can create media with invalid name #{name}"
  end

  test "should not create with invalid url" do
    path = RFauxFactory.gen_alpha
    media_invalid_url = @new_medium.clone.update(:path => path)
    post :create, params: { :medium => media_invalid_url }
    assert_response :unprocessable_entity, "Can create media with invalid url #{path}"
  end

  test "should not create with invalid os family" do
    os_family = RFauxFactory.gen_alpha
    media_invalid_os_family = @new_medium.clone.update(:os_family => os_family)
    post :create, params: { :medium => media_invalid_os_family }
    assert_response :unprocessable_entity, "Can create media with invalid os_family #{os_family}"
  end

  test "should update with valid name" do
    name = RFauxFactory.gen_alpha
    put :update, params: { :id => Medium.first.id, :name => name }
    assert_response :success
    assert_equal name, JSON.parse(@response.body)["name"], "Can't update media with valid name #{name}"
  end

  test "should update with valid url" do
    path = "http://www.example.com/"
    put :update, params: { :id => Medium.first.id, :path => path }
    assert_response :success
    assert_equal path, JSON.parse(@response.body)["path"], "Can't update media with valid url #{path}"
  end

  test "should update with valid os family" do
    os_family = Operatingsystem.families.sample
    put :update, params: { :id => Medium.first.id, :os_family => os_family }
    assert_response :success
    assert_equal os_family, JSON.parse(@response.body)["os_family"], "Can't update media with valid os family #{os_family}"
  end

  test "should not update with invalid name" do
    name = ""
    put :update, params: { :id => Medium.first.id, :medium => { :name => name } }
    assert_response :unprocessable_entity, "Can update media with invalid name #{name}"
  end

  test "should not update with invalid url" do
    path = RFauxFactory.gen_alpha
    put :update, params: { :id => Medium.first.id, :medium => { :path => path } }
    assert_response :unprocessable_entity, "Can update media with invalid path #{path}"
  end

  test "should not update with invalid os family" do
    os_family = RFauxFactory.gen_alpha
    put :update, params: { :id => Medium.first.id, :medium => { :os_family => os_family } }
    assert_response :unprocessable_entity, "Can update media with invalid os family #{os_family}"
  end

  test "should destroy medium" do
    assert_difference('Medium.unscoped.count', -1) do
      delete :destroy, params: { :id => media(:unused).id.to_param }
    end
    assert_response :success
  end
end
