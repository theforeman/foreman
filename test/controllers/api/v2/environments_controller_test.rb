require 'test_helper'

class Api::V2::EnvironmentsControllerTest < ActionController::TestCase
  development_environment = { :name => 'Development' }

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:environments)
    envs = ActiveSupport::JSON.decode(@response.body)
    assert !envs.empty?
  end

  test "should show environment" do
    get :show, params: { :id => environments(:production).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    refute show_response.empty?
  end

  test "should show environment by id or name" do
    get :show, params: { :id => environments(:production).id }
    assert_response :success
    get :show, params: { :id => environments(:production).to_param }
    assert_response :success
    get :show, params: { :id => environments(:production).name }
    assert_response :success
  end

  test "should create environment" do
    assert_difference('Environment.unscoped.count') do
      post :create, params: { :environment => development_environment }
    end
    assert_response :created
  end

  test "should create new environment with organization" do
    organization = Organization.first
    assert_difference 'Environment.unscoped.count' do
      post :create, params: { :environment => {:name => "some_environment", :organization_ids => [organization.id]} }, session: set_session_user
      response = JSON.parse(@response.body)
      assert_equal response['organizations'].length, 1
      assert_equal response['organizations'][0]['id'], organization.id
    end
    assert_response :created, "Can't create environment with organization #{organization.name}"
  end

  test "should create new environment with location" do
    location = Location.first
    assert_difference 'Environment.unscoped.count' do
      post :create, params: { :environment => {:name => "some_environment", :location_ids => [location.id]} }, session: set_session_user
      response = JSON.parse(@response.body)
      assert_equal response['locations'].length, 1
      assert_equal response['locations'][0]['id'], location.id
    end
    assert_response :created, "Can't create environment with location #{location.name}"
  end

  test "should not create with invalid name" do
    name = ""
    post :create, params: { :environment => { :name => name } }
    assert_response :unprocessable_entity, "Can create environment with invalid name #{name}"
  end

  test "should update with valid name" do
    environment = FactoryBot.create(:environment)
    new_environment_name = RFauxFactory.gen_alphanumeric
    post :update, params: {:id => environment.id, :environment => {:name => new_environment_name} }, session: set_session_user
    assert_equal JSON.parse(@response.body)['name'], new_environment_name, "Can't update environment with valid name #{name}"
  end

  test "should not update with invalid name" do
    name = ""
    put :update, params: { :id => environments(:production).to_param, :environment => { :name => name } }
    assert_response :unprocessable_entity, "Can update environment with invalid name #{name}"
  end

  test "should update environment" do
    put :update, params: { :id => environments(:production).to_param, :environment => development_environment }
    assert_response :success
  end

  test "should update environment with organization" do
    env = FactoryBot.create(:environment)
    organization = Organization.first
    put :update, params: { :id => env.id, :environment => { :organization_ids => [organization.id]} }
    response = JSON.parse(@response.body)
    assert_equal response['organizations'].length, 1
    assert_equal response['organizations'][0]['id'], organization.id
    assert_response :success, "Can't update environment with organization #{organization.name}"
  end

  test "should update environment with location" do
    env = FactoryBot.create(:environment)
    location = Location.first
    put :update, params: { :id => env.id, :environment => { :location_ids => [location.id]} }
    response = JSON.parse(@response.body)
    assert_equal response['locations'].length, 1
    assert_equal response['locations'][0]['id'], location.id
    assert_response :success, "Can't update environment with location #{location.name}"
  end

  test "should destroy environments" do
    assert_difference('Environment.unscoped.count', -1) do
      delete :destroy, params: { :id => environments(:testing).to_param }
    end
    assert_response :success
  end
end
