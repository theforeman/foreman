require 'test_helper'

class Api::V2::ComputeProfilesControllerTest < ActionController::TestCase
  context 'index test' do
    def setup
      @org = FactoryBot.create(:organization)
      @loc = FactoryBot.create(:location)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:compute_profiles)
      compute_profiles = ActiveSupport::JSON.decode(@response.body)
      assert !compute_profiles.empty?
    end

    test "should get index with organization and location params" do
      get :index, params: { :location_id => @loc.id, :organization_id => @org.id}
      assert_response :success
      assert_not_nil assigns(:compute_profiles)
      compute_profiles = ActiveSupport::JSON.decode(@response.body)
      assert !compute_profiles.empty?
    end
  end

  test "should show individual record" do
    Foreman::Model::EC2.any_instance.expects(:normalize_vm_attrs).returns({})
    get :show, params: { :id => compute_profiles(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create compute profile" do
    name = '4-Xlarge'
    assert_difference('ComputeProfile.count') do
      post :create, params: { :compute_profile => {:name => name} }
    end
    assert_response :created
    assert_equal JSON.parse(@response.body)['name'], name, "Can't create compute profile with valid name #{name}"
  end

  test "should not create compute profile" do
    assert_difference('ComputeProfile.count', 0) do
      post :create, params: { :compute_profile => {:name => ''} }
    end
    assert_response :unprocessable_entity
    assert_match "Name can't be blank", @response.body
  end

  test "should update compute_profile" do
    Foreman::Model::EC2.any_instance.expects(:normalize_vm_attrs).returns({})
    name = 'new name'
    put :update, params: { :id => compute_profiles(:one).to_param, :compute_profile => {:name => name } }
    assert_response :success
    assert_equal JSON.parse(@response.body)['name'], name, "Can't update compute profile with valid name #{name}"
  end

  test "should not update compute_profile" do
    put :update, params: { :id => compute_profiles(:one).to_param, :compute_profile => {:name => '' } }
    assert_response :unprocessable_entity
    assert_match "Name can't be blank", @response.body
  end

  test "should destroy compute profile" do
    assert_difference('ComputeProfile.count', -1) do
      delete :destroy, params: { :id => compute_profiles(:three).to_param }
    end
    assert_response :success
  end
end
