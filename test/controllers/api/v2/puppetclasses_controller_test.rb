require 'test_helper'

class Api::V2::PuppetclassesControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'test_puppetclass' }

  test "should get index" do
    get :index
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses.empty?
    assert puppetclasses['results'].is_a?(Hash)
  end

  test "should get index with style=list" do
    get :index, params: { :style => 'list' }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses.empty?
    assert puppetclasses['results'].is_a?(Array)
  end

  context 'with taxonomy given' do
    let(:default_organization) { Organization.first }
    let(:default_location) { Location.first }
    let(:example_environment) do
      FactoryBot.create(:environment, :locations => [default_location], :organizations => [default_organization])
    end
    let(:example_puppetclass) { FactoryBot.create(:puppetclass, :environments => [example_environment]) }
    let(:eager_load) { [default_organization, default_location, example_environment, example_puppetclass] }
    setup do
      eager_load
    end

    test 'index should return puppetclasses only in Organization' do
      get :index, params: { :organization_id => default_organization.id }
      includes_example_puppetclass
      assert_response :success
    end

    test 'index should return puppetclasses only in Organization' do
      get :index, params: { :location_id => default_location.id }
      includes_example_puppetclass
      assert_response :success
    end

    test 'index should return puppetclasses only in Organization' do
      get :index, params: { :location_id => default_location.id, :organization_id => default_organization.id }
      includes_example_puppetclass
      assert_response :success
    end

    def includes_example_puppetclass
      puppetclasses = ActiveSupport::JSON.decode(@response.body)
      assert_include puppetclasses['results'].map { |_, v| v[0]['id'] }, example_puppetclass.id
    end
  end

  test "should create puppetclass" do
    assert_difference('Puppetclass.count') do
      post :create, params: { :puppetclass => valid_attrs }
    end
    assert_response :created
  end

  test "should update puppetclass" do
    put :update, params: { :id => puppetclasses(:one).to_param, :puppetclass => valid_attrs }
    assert_response :success
  end

  test "should destroy puppetclasss" do
    HostClass.delete_all
    HostgroupClass.delete_all
    assert_difference('Puppetclass.count', -1) do
      delete :destroy, params: { :id => puppetclasses(:one).to_param }
    end
    assert_response :success
  end

  test "should get puppetclasses for given host only" do
    host1 = FactoryBot.create(:host, :with_puppetclass)
    FactoryBot.create(:host, :with_puppetclass)
    get :index, params: { :host_id => host1.to_param }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert_equal host1.puppetclasses.map(&:name).sort, puppetclasses['results'].keys.sort
  end

  test "should not get puppetclasses for nonexistent host" do
    get :index, params: { "search" => "host = imaginaryhost.nodomain.what" }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert puppetclasses['results'].empty?
  end

  test "should get puppetclasses for hostgroup" do
    get :index, params: { :hostgroup_id => hostgroups(:common).to_param }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses['results'].empty?
    assert_equal 4, puppetclasses['results'].length
  end

  test "should get puppetclasses for environment" do
    get :index, params: { :environment_id => environments(:production).to_param }
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert !puppetclasses['results'].empty?
    assert_equal 7, puppetclasses['results'].length
  end

  test "should show error if optional nested environment does not exist" do
    get :index, params: { :environment_id => 'nonexistent' }
    assert_response 404
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    assert_equal "Environment not found by id 'nonexistent'", puppetclasses['message']
  end

  test "should show puppetclass for host" do
    host = FactoryBot.create(:host, :with_puppetclass)
    get :show, params: { :host_id => host.to_param, :id => host.puppetclasses.first.id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    refute_empty show_response
  end

  test "should show puppetclass for hostgroup" do
    get :show, params: { :hostgroup_id => hostgroups(:common).to_param, :id => puppetclasses(:one).id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should show puppetclass for environment" do
    get :show, params: { :environment_id => environments(:production), :id => puppetclasses(:one).id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    refute_empty show_response
  end

  # CRUD actions - same test as V1
  test "should get index" do
    get :index
    assert_response :success
    puppetclasses = ActiveSupport::JSON.decode(@response.body)
    refute_empty puppetclasses
  end

  # FYI - show puppetclass doesn't work in V1
  test "should show puppetclass with no nesting" do
    get :show, params: { :id => puppetclasses(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    refute_empty show_response
  end

  test "should create puppetclass" do
    assert_difference('Puppetclass.count') do
      post :create, params: { :puppetclass => valid_attrs }
    end
    assert_response :success
  end

  test "should update puppetclass" do
    put :update, params: { :id => puppetclasses(:one).to_param, :puppetclass => valid_attrs }
    assert_response :success
  end

  test "should destroy puppetclasss" do
    HostClass.delete_all
    HostgroupClass.delete_all
    assert_difference('Puppetclass.count', -1) do
      delete :destroy, params: { :id => puppetclasses(:one).to_param }
    end
    assert_response :success
  end

  test "should not remove puppetclass params" do
    klass = FactoryBot.create(:puppetclass, :environments => [FactoryBot.create(:environment)])
    FactoryBot.create(:puppetclass_lookup_key, :as_smart_class_param, :puppetclass => klass)
    assert_equal 1, klass.class_params.length
    put :update, params: { :id => klass.id, :smart_class_parameter_ids => [] }
    klass.reload
    assert_equal 1, klass.class_params.length
  end
end
