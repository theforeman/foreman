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
    get :show, params: { :id => filters(:manager_1).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test_attributes :pid => 'b8631d0a-a71a-41aa-9f9a-d12d62adc496'
  test "should create filter" do
    valid_attrs = { :role_id => roles(:destroy_hosts).id, :permission_ids => [permissions(:view_architectures).id] }
    assert_difference('Filter.count') do
      post :create, params: { :filter => valid_attrs }
    end
    assert_response :created
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal show_response["permissions"].first["name"], "view_architectures"
  end

  test "should create filter with scoped organization" do
    role = FactoryBot.create(:role, :organization_ids => [taxonomies(:organization1).id], :name => "role_test")

    filter = { :role_id => role.id, :permission_ids => [permissions(:view_architectures).id]}
    assert_difference('Filter.count') do
      post :create, params: { :filter => filter, :organization_id => taxonomies(:organization1).id}
    end
    assert_response :created
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal show_response["permissions"].first["name"], "view_architectures"
  end

  test "should create non-overridable filter" do
    role = FactoryBot.create(:role, :name => 'New Role')
    assert_difference('Filter.count') do
      post :create, params: { :filter => { :role_id => role.id, :permission_ids => [permissions(:view_architectures).id] } }
    end
    assert_response :created
    result = JSON.parse(@response.body)
    assert_equal false, result['override?']
    assert_equal role.id, result['role']['id']
  end

  test "should update filter" do
    valid_attrs = { :role_id => roles(:destroy_hosts).id, :permission_ids => [permissions(:create_hosts).id] }
    put :update, params: { :id => filters(:destroy_hosts_1).to_param, :filter => valid_attrs }
    assert_response :success
  end

  test_attributes :pid => 'f0c56fd8-c91d-48c3-ad21-f538313b17eb'
  test "should destroy filters" do
    assert_difference('Filter.count', -1) do
      delete :destroy, params: { :id => filters(:destroy_hosts_1).to_param }
    end
    assert_response :success
  end

  context "with organizations and locations" do
    before do
      @org = taxonomies(:organization1)
      @loc = taxonomies(:location1)
    end

    test "should create overridable filter" do
      filter_loc = taxonomies(:location2)
      filter_org = taxonomies(:organization2)
      role = FactoryBot.create(:role, :name => 'New Role', :locations => [@loc], :organizations => [@org])
      assert_difference('Filter.count') do
        filter_attr = {
          :role_id => role.id,
          :permission_ids => [permissions(:view_domains).id],
          :override => true,
          :location_ids => [filter_loc.id],
          :organization_ids => [filter_org.id],
        }
        post :create, params: { :filter => filter_attr }
      end
      assert_response :created
      result = JSON.parse(@response.body)
      assert_equal true, result['override?']
      assert_equal role.id, result['role']['id']
      assert_equal filter_org.id, result['organizations'][0]['id']
      assert_equal filter_loc.id, result['locations'][0]['id']
    end

    test "should disable filter override" do
      role = FactoryBot.create(:role, :name => 'New Role', :locations => [@loc], :organizations => [@org])
      filter = FactoryBot.create(:filter,
        :role_id => role.id,
        :permission_ids => [permissions(:view_domains).id],
        :override => true,
        :locations => [taxonomies(:location2)],
        :organizations => [taxonomies(:organization2)]
      )
      put :update, params: { :id => filter.to_param, :filter => { :override => false } }
      assert_response :success
      filter.reload
      assert_equal false, filter.override
      assert_equal @org, filter.organizations.first
      assert_equal @loc, filter.locations.first
    end

    test "should create filter without override" do
      role = FactoryBot.create(:role, :name => 'New Role', :location_ids => [@loc.id], :organization_ids => [@org.id])
      assert_difference('Filter.count') do
        post :create, params: { :filter => { :role_id => role.id, :permission_ids => [permissions(:view_domains).id] } }
      end
      assert_response :created
      result = JSON.parse(@response.body)
      refute result['override?']
      assert_equal @org.id, result['organizations'][0]['id']
      assert_equal @loc.id, result['locations'][0]['id']
    end

    test "should not create overridable filter" do
      role = FactoryBot.create(:role, :name => 'New Role')
      assert_difference('Filter.count', 0) do
        filter_attr = {
          :role_id => role.id,
          :permission_ids => [permissions(:view_architectures).id],
          :override => true,
          :location_ids => [@loc.id],
          :organization_ids => [@org.id],
        }
        post :create, params: { :filter => filter_attr }
      end
      assert_response :unprocessable_entity
      assert_match "You can't assign organizations to this resource", @response.body
      assert_match "You can't assign locations to this resource", @response.body
    end
  end

  context "with organizations" do
    before do
      @org = FactoryBot.create(:organization)
    end

    test "filter can override taxonomies" do
      valid_attrs = { :role_id => roles(:destroy_hosts).id, :permission_ids => [permissions(:view_media).id], :organization_ids => [@org.id], :override => true }
      assert_difference('Filter.count') do
        post :create, params: { :filter => valid_attrs }
      end
      assert_response :created
      assert assigns(:filter).organizations.include? @org
    end

    test "taxonomies are ignored if override is not explicitly enabled" do
      valid_attrs = { :role_id => roles(:destroy_hosts).id, :permission_ids => [permissions(:view_domains).id], :organization_ids => [@org.id] }
      assert_difference('Filter.count') do
        post :create, params: { :filter => valid_attrs }
      end
      assert_response :created
      refute assigns(:filter).organizations.include? @org
    end
  end
end
