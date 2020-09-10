require 'test_helper'

class Api::V2::SubnetsControllerTest < ActionController::TestCase
  valid_v4_attrs = { :name => 'QA2', :network_type => 'IPv4', :network => '10.35.2.27', :mask => '255.255.255.0' }
  valid_v6_attrs = { :name => 'QA2', :network_type => 'IPv6', :network => '2001:db8::', :mask => 'ffff:ffff:ffff:ffff::', :ipam => 'None' }

  test "index content is a JSON array" do
    get :index
    subnets = ActiveSupport::JSON.decode(@response.body)
    assert subnets['results'].is_a?(Array)
    assert_response :success
    assert !subnets.empty?
  end

  test "should show individual record" do
    get :show, params: { :id => subnets(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create IPv4 subnet" do
    assert_difference('Subnet.unscoped.count') do
      post :create, params: { :subnet => valid_v4_attrs }
    end
    assert_response :created
  end

  test "should create IPv4 subnet if type is not defined" do
    assert_difference('Subnet.unscoped.count') do
      post :create, params: { :subnet => valid_v4_attrs.reject { |k, v| k == :network_type } }
    end
    subnet = Subnet.unscoped.find_by_name(valid_v4_attrs[:name])
    assert_equal valid_v4_attrs[:network_type], subnet.network_type
    assert_response :created
  end

  test "should create IPv6 subnet" do
    assert_difference('Subnet.unscoped.count') do
      post :create, params: { :subnet => valid_v6_attrs }
    end
    assert_response :created
  end

  test "does not create subnet with non-existent domain" do
    post :create, params: { :subnet => valid_v4_attrs.merge(:domain_ids => [1, 2]) }
    assert_response :unprocessable_entity
  end

  test "should update subnet" do
    put :update, params: { :id => subnets(:one).to_param, :subnet => valid_v4_attrs }
    assert_response :success
  end

  test "should not update subnet and change type" do
    put :update, params: { :id => subnets(:one).to_param, :subnet => valid_v6_attrs }
    assert_response :unprocessable_entity
  end

  test "should destroy subnets" do
    assert_difference('Subnet.unscoped.count', -1) do
      delete :destroy, params: { :id => subnets(:four).to_param }
    end
    assert_response :success
  end

  test "should NOT destroy subnet that is in use" do
    assert_difference('Subnet.unscoped.count', 0) do
      delete :destroy, params: { :id => subnets(:one).to_param }
    end
    assert_response :unprocessable_entity
  end

  test "delete destroys subnet not in use" do
    subnet = Subnet.first
    subnet.hosts.clear
    subnet.hostgroups.clear
    subnet.interfaces.clear
    subnet.domains.clear
    as_admin { delete :destroy, params: { :id => subnet.id } }
    ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    assert !Subnet.exists?(:id => subnet.id)
  end

  context 'free ip' do
    context 'subnet with ipam' do
      setup do
        @subnet = FactoryBot.create(:subnet_ipv4, :network => '192.168.2.0', :from => '192.168.2.10', :to => '192.168.2.12',
                                     :ipam => IPAM::MODES[:db])
      end

      test "should get free ip" do
        get :freeip, params: { :id => @subnet.to_param }
        assert_response :success
        show_response = ActiveSupport::JSON.decode(@response.body)
        assert !show_response.empty?
        assert_equal '192.168.2.10', show_response['freeip']
      end

      test "should get free ip and honor excluded ips" do
        get :freeip, params: { :id => @subnet.to_param, :excluded_ips => ['192.168.2.10'] }
        assert_response :success
        show_response = ActiveSupport::JSON.decode(@response.body)
        assert !show_response.empty?
        assert_equal '192.168.2.11', show_response['freeip']
      end
    end

    context 'subnet without ipam' do
      setup do
        @subnet = FactoryBot.create(:subnet_ipv4, :network => '192.168.2.0')
      end

      test "should not get free ip" do
        get :freeip, params: { :id => @subnet.to_param }
        assert_response :success
        show_response = ActiveSupport::JSON.decode(@response.body)
        assert !show_response.empty?
        assert_nil show_response['freeip']
      end
    end
  end

  test "user without view_params permission can't see subnet parameters" do
    subnet_with_parameter = FactoryBot.create(:subnet_ipv4, :with_parameter)
    setup_user "view", "subnets"
    get :show, params: { :id => subnet_with_parameter.to_param, :format => 'json' }
    assert_empty JSON.parse(response.body)['parameters']
  end

  test "user with view_params permission can see subnet parameters" do
    subnet_with_parameter = FactoryBot.create(:subnet_ipv4, :with_parameter)
    setup_user "view", "subnets"
    setup_user "view", "params"
    get :show, params: { :id => subnet_with_parameter.to_param, :format => 'json' }
    assert_not_empty JSON.parse(response.body)['parameters']
  end

  context 'hidden parameters' do
    test "should show a subnet parameter as hidden unless show_hidden_parameters is true" do
      subnet = FactoryBot.create(:subnet_ipv4)
      subnet.subnet_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, params: { :id => subnet.id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal '*****', show_response['parameters'].first['value']
    end

    test "should show a subnet parameter as unhidden when show_hidden_parameters is true" do
      subnet = FactoryBot.create(:subnet_ipv4)
      subnet.subnet_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, params: { :id => subnet.id, :show_hidden_parameters => 'true' }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 'bar', show_response['parameters'].first['value']
    end
  end

  test "should create with parameter" do
    param_params = { :name => "foo", :value => "bar" }
    post :create, params: { :subnet => valid_v4_attrs.clone.update(:subnet_parameters_attributes => [param_params]) }
    assert_response :success
    assert_include param_params[:name], JSON.parse(@response.body)["parameters"][0]["name"], "Can't create subnet with valid parameters name #{param_params[:name]}"
    assert_include param_params[:value], JSON.parse(@response.body)["parameters"][0]["value"], "Can't create subnet with valid parameters value #{param_params[:value]}"
  end

  test "should create with parameters and valid separator" do
    param_params = { :name => RFauxFactory.gen_strings().values.join(","), :value => "bar" }
    post :create, params: { :subnet => valid_v4_attrs.clone.update(:subnet_parameters_attributes => [param_params]) }
    assert_response :success
    assert_include param_params[:name], JSON.parse(@response.body)["parameters"][0]["name"], "Can't create subnet with valid parameters name #{param_params[:name]}"
    assert_include param_params[:value], JSON.parse(@response.body)["parameters"][0]["value"], "Can't create subnet with valid parameters value #{param_params[:value]}"
  end

  test "should update existing subnet parameters with value" do
    subnet = FactoryBot.create(:subnet_ipv4)
    param_params = { :name => "foo", :value => "bar" }
    subnet.subnet_parameters.create!(param_params)
    put :update, params: { :id => subnet.id, :subnet => { :subnet_parameters_attributes => [{ :name => param_params[:name], :value => "new_value" }] } }
    assert_response :success
    assert param_params[:name], subnet.parameters.first.name
  end

  test "should update existing subnet parameters with key and value" do
    subnet = FactoryBot.create(:subnet_ipv4)
    param_params = { :name => "foo", :value => "bar" }
    new_param_params = { :name => "new_key", :value => "new_value" }
    subnet.subnet_parameters.create!(param_params)
    put :update, params: { :id => subnet.id, :subnet => { :subnet_parameters_attributes => [new_param_params] } }
    assert_response :success
    assert_equal new_param_params[:name], subnet.parameters.first.name
    assert_equal new_param_params[:value], subnet.parameters.first.value
    assert_equal 1, subnet.parameters.count
  end

  test "should delete existing subnet parameters" do
    subnet = FactoryBot.create(:subnet_ipv4)
    param_1 = { :name => "foo", :value => "bar" }
    param_2 = { :name => "boo", :value => "test" }
    subnet.subnet_parameters.create!([param_1, param_2])
    put :update, params: { :id => subnet.id, :subnet => { :subnet_parameters_attributes => [{ :name => param_1[:name], :value => "new_value" }] } }
    assert_response :success
    assert_equal 1, subnet.parameters.count
  end

  test "should return subnets when searching by location as non-admin user" do
    org = FactoryBot.create(:organization)
    loc = FactoryBot.create(:location)
    FactoryBot.create(:subnet_ipv4, :organizations => [org], :locations => [loc])
    user = FactoryBot.create(:user, :organizations => [org], :locations => [loc], :default_organization_id => org.id,
                             :default_location_id => loc.id, :roles => [roles(:manager)])
    as_user user do
      get :index, params: { :location_id => loc.id }
    end

    assert_response :success
  end

  test "should return subnets when searching by location as non-admin user and role has taxonomies" do
    org = FactoryBot.create(:organization)
    loc = FactoryBot.create(:location)
    FactoryBot.create(:subnet_ipv4, :organizations => [org], :locations => [loc])
    manager = roles(:manager)
    role = manager.clone :name => "Clonned manager", :organizations => [org], :locations => [loc]
    role.save!
    user = FactoryBot.create(:user, :organizations => [org], :locations => [loc], :default_organization_id => org.id,
                             :default_location_id => loc.id, :roles => [role])
    as_user user do
      get :index, params: { :location_id => loc.id }
    end
    assert_response :success
  end
end
