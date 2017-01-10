require 'test_helper'

class Api::V2::FiltersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:filters)
    filters = ActiveSupport::JSON.decode(@response.body)
    assert !filters.empty?
  end

  test "should show individual record" do
    get :show, { :id => filters(:manager_1).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create filter" do
    valid_attrs = { :role_id => roles(:destroy_hosts).id, :permission_ids => [permissions(:view_architectures).id] }
    assert_difference('Filter.count') do
      post :create, { :filter => valid_attrs }
    end
    assert_response :created
  end

  test "should update filter" do
    valid_attrs = { :role_id => roles(:destroy_hosts).id, :permission_ids => [permissions(:create_hosts).id] }
    put :update, { :id => filters(:destroy_hosts_1).to_param, :filter => valid_attrs }
    assert_response :success
  end

  test "should destroy filters" do
    assert_difference('Filter.count', -1) do
      delete :destroy, { :id => filters(:destroy_hosts_1).to_param }
    end
    assert_response :success
  end

  context "with organizations" do
    before do
      @org = FactoryGirl.create(:organization)
    end

    test "filter can override taxonomies" do
      valid_attrs = { :role_id => roles(:destroy_hosts).id, :permission_ids => [permissions(:view_media).id], :organization_ids => [@org.id], :override => true }
      assert_difference('Filter.count') do
        post :create, { :filter => valid_attrs }
      end
      assert_response :created
      assert assigns(:filter).organizations.include? @org
    end

    test "taxonomies are ignored if override is not explicitly enabled" do
      valid_attrs = { :role_id => roles(:destroy_hosts).id, :permission_ids => [permissions(:view_domains).id], :organization_ids => [@org.id] }
      assert_difference('Filter.count') do
        post :create, { :filter => valid_attrs }
      end
      assert_response :created
      refute assigns(:filter).organizations.include? @org
    end
  end
end
