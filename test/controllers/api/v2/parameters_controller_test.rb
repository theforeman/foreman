require 'test_helper'

class Api::V2::ParametersControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'special_key', :value => '123' }

  def setup
    @host = FactoryBot.create(:host, :with_parameter)
  end

  test "should get index for specific host" do
    get :index, params: {:host_id => @host.to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty parameters
  end

  test "should get index for specific domain" do
    get :index, params: { :domain_id => domains(:mydomain).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty parameters
  end

  test "should get index for specific hostgroup" do
    get :index, params: {:hostgroup_id => hostgroups(:common).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty parameters
  end

  test "should get index for specific os" do
    get :index, params: {:operatingsystem_id => operatingsystems(:redhat).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty parameters
  end

  test "should get index for specific location" do
    get :index, params: { :location_id => taxonomies(:location1).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty parameters
  end

  test "should get index for specific organization" do
    get :index, params: { :organization_id => taxonomies(:organization1).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty parameters
  end

  test "should show a host parameter" do
    get :show, params: { :host_id => @host.to_param, :id => @host.parameters.first.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show a domain parameter" do
    get :show, params: {:domain_id => domains(:mydomain).to_param, :id => parameters(:domain).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show a hostgroup parameter" do
    get :show, params: {:hostgroup_id => hostgroups(:common).to_param, :id => parameters(:group).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show an os parameter" do
    get :show, params: {:operatingsystem_id => operatingsystems(:redhat).to_param, :id => parameters(:os).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show a location parameter" do
    get :show, params: { :location_id => taxonomies(:location1).to_param, :id => parameters(:location).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show an organization parameter" do
    get :show, params: { :organization_id => taxonomies(:organization1).to_param, :id => parameters(:organization).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show a subnet parameter" do
    get :show, params: {:subnet_id => subnets(:five).to_param, :id => parameters(:subnet).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show correct parameter if id is name even if name is not unique" do
    # parameters(:os).name = 'os1' in fixtures
    # create DomainParamter with name name
    assert Domain.first.parameters.create(:name => 'os1')
    param = parameters(:os)
    get :show, params: {:operatingsystem_id => operatingsystems(:redhat).to_param, :id => param.name }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal param.id, show_response['id']
  end

  test "should create host parameter" do
    assert_difference('@host.parameters.count') do
      post :create, params: { :host_id => @host.to_param, :parameter => valid_attrs }
    end
    assert_response :created
  end

  test "should create host parameter with lone taxonomies" do
    Location.stubs(:one?).returns(true)
    assert_difference('@host.parameters.count') do
      post :create, params: { :host_id => @host.to_param, :parameter => valid_attrs }
    end
    assert_response :created
  end

  test "should create domain parameter" do
    domain = domains(:mydomain)
    assert_difference('domain.parameters.count') do
      post :create, params: { :domain_id => domain.to_param, :parameter => valid_attrs }
    end
    assert_response :created
  end

  test "should create subnet parameter" do
    subnet = subnets(:five)
    assert_difference('subnet.parameters.count') do
      post :create, params: { :subnet_id => subnet.to_param, :parameter => valid_attrs }
    end
    assert_response :created
    assert_equal JSON.parse(@response.body)['name'], valid_attrs[:name], "Can't create subnet parameter with valid name #{valid_attrs[:name]}"
    assert_equal JSON.parse(@response.body)['value'], valid_attrs[:value], "Can't create subnet parameter with valid value #{valid_attrs[:value]}"
  end

  test "should create subnet parameter with valid separator in value" do
    subnet = subnets(:five)
    name = 'key'
    value = RFauxFactory.gen_strings().values.join(", ")
    assert_difference('subnet.parameters.count') do
      post :create, params: { :subnet_id => subnet.id, :parameter => { :name => name, :value => value } }
    end
    assert_response :created
    assert_equal JSON.parse(@response.body)['name'], name, "Can't create subnet parameter with valid name #{name}"
    assert_equal JSON.parse(@response.body)['value'], value, "Can't create subnet parameter with valid value #{value}"
  end

  test "should not create duplicate subnet parameter" do
    subnet = subnets(:five)
    subnet.subnet_parameters << SubnetParameter.create(valid_attrs)
    assert_difference('subnet.parameters.count', 0) do
      post :create, params: { :subnet_id => subnet.id, :parameter => valid_attrs }
    end
    assert_response :unprocessable_entity
    assert_match 'Name has already been taken', @response.body
  end

  test "should not create with invalid separator in name" do
    subnet = subnets(:five)
    assert_difference('subnet.parameters.count', 0) do
      post :create, params: { :subnet_id => subnet.id, :parameter => { :name => 'name with space', :value => '123' } }
    end
    assert_response :unprocessable_entity
  end

  test "should not update with invalid separator in name" do
    subnet = subnets(:five)
    param_name = subnet.parameters.first.name
    put :update, params: { :subnet_id => subnet.id, :id => subnet.parameters.first.id, :parameter => { :name => 'name with space', :value => '123' } }
    assert_response :unprocessable_entity
    assert_equal param_name, Subnet.unscoped.find_by_name(subnet.name).parameters.
        order("parameters.updated_at").last.name
  end

  test "should create hostgroup parameter" do
    hostgroup = hostgroups(:common)
    assert_difference('hostgroup.group_parameters.count') do
      post :create, params: { :hostgroup_id => hostgroup.to_param, :parameter => valid_attrs }
    end
    assert_response :created
  end

  test "should create hostgroup parameter with lone taxonomies" do
    Organization.stubs(:one?).returns(true)
    hostgroup = hostgroups(:common)
    assert_difference('hostgroup.group_parameters.count') do
      post :create, params: { :hostgroup_id => hostgroup.to_param, :parameter => valid_attrs }
    end
    assert_response :created
  end

  test "should create os parameter" do
    os = operatingsystems(:redhat)
    assert_difference('os.parameters.count') do
      post :create, params: { :operatingsystem_id => os.to_param, :parameter => valid_attrs }
    end
    assert_response :created
  end

  test "should update nested host parameter" do
    put :update, params: { :host_id => @host.to_param, :id => @host.parameters.first.to_param, :parameter => valid_attrs }
    assert_response :success
    assert_equal '123', Host.unscoped.find_by_name(@host.name).parameters.
      order("parameters.updated_at").last.value
  end

  test "should update nested domain parameter" do
    put :update, params: { :domain_id => domains(:mydomain).to_param, :id => parameters(:domain).to_param, :parameter => valid_attrs }
    assert_response :success
    assert_equal Domain.unscoped.find_by_name("mydomain.net").parameters.
      order("parameters.updated_at").last.value, "123"
  end

  test "should update nested subnet parameter" do
    put :update, params: { :subnet_id => subnets(:five).to_param, :id => parameters(:subnet).to_param, :parameter => valid_attrs }
    assert_response :success
    assert_equal Subnet.unscoped.find_by_name("five").parameters.
      order("parameters.updated_at").last.value, "123"
  end

  test "should update nested hostgroup parameter" do
    put :update, params: { :hostgroup_id => hostgroups(:common).to_param, :id => parameters(:group).to_param, :parameter => valid_attrs }
    assert_response :success
    assert_equal Hostgroup.unscoped.find_by_name("Common").group_parameters.
      order("parameters.updated_at").last.value, "123"
  end

  test "should update nested os parameter" do
    put :update, params: { :operatingsystem_id => operatingsystems(:redhat).to_param, :id => parameters(:os).to_param, :parameter => valid_attrs }
    assert_response :success
    assert_equal Operatingsystem.unscoped.find_by_name("Redhat").parameters.
      order("parameters.updated_at").last.value, "123"
  end

  test "should destroy nested host parameter" do
    assert_difference('HostParameter.count', -1) do
      delete :destroy, params: { :host_id => @host.to_param, :id => @host.parameters.first.to_param }
    end
    assert_response :success
  end

  test "should destroy nested domain parameter" do
    assert_difference('DomainParameter.count', -1) do
      delete :destroy, params: { :domain_id => domains(:mydomain).to_param, :id => parameters(:domain).to_param }
    end
    assert_response :success
  end

  test "should destroy nested subnet parameter" do
    assert_difference('SubnetParameter.count', -1) do
      delete :destroy, params: { :subnet_id => subnets(:five).to_param, :id => parameters(:subnet).to_param }
    end
    assert_response :success
  end

  test "should destroy Hostgroup parameter" do
    assert_difference('GroupParameter.count', -1) do
      delete :destroy, params: { :hostgroup_id => hostgroups(:common).to_param, :id => parameters(:group).to_param }
    end
    assert_response :success
  end

  test "should destroy nested os parameter" do
    assert_difference('OsParameter.count', -1) do
      delete :destroy, params: { :operatingsystem_id => operatingsystems(:redhat).to_param, :id => parameters(:os).to_param }
    end
    assert_response :success
  end

  test "should reset nested host parameter" do
    assert_difference('HostParameter.count', -1) do
      delete :reset, params: { :host_id => @host.to_param }
    end
    assert_response :success
  end

  test "should reset nested domain parameter" do
    assert_difference('DomainParameter.count', -1) do
      delete :reset, params: { :domain_id => domains(:mydomain).to_param }
    end
    assert_response :success
  end

  test "should reset nested subnet parameter" do
    assert_difference('SubnetParameter.count', -1) do
      delete :reset, params: { :subnet_id => subnets(:five).to_param }
    end
    assert_response :success
  end

  test "should reset Hostgroup parameter" do
    assert_difference('GroupParameter.count', -1) do
      delete :reset, params: { :hostgroup_id => hostgroups(:common).to_param }
    end
    assert_response :success
  end

  test "should reset nested os parameters" do
    assert_difference('OsParameter.count', -1) do
      delete :reset, params: { :operatingsystem_id => operatingsystems(:redhat).id }
    end
    assert_response :success
  end

  context "scoped search" do
    def assert_filtering_works(resource, id)
      post :create, params: { "#{resource}_id".to_sym => id, :parameter => { :name => 'parameter2', :value => 'X' } }
      get :index, params: { "#{resource}_id".to_sym => id, :search => 'name = parameter2' }
      assert_response :success
      assert_not_nil assigns(:parameters)
      parameters = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameters['results'][0]['name'], 'parameter2'
      assert_equal parameters['subtotal'], 1
    end

    test "should get index for specific host fitered by name" do
      assert_filtering_works :host, @host.to_param
    end

    test "should get index for specific domain fitered by name" do
      assert_filtering_works :domain, domains(:mydomain).to_param
    end

    test "should get index for specific subnet fitered by name" do
      assert_filtering_works :subnet, subnets(:five).to_param
    end

    test "should get index for specific hostgroup fitered by name" do
      assert_filtering_works :hostgroup, hostgroups(:common).to_param
    end

    test "should get index for specific os filtred by name" do
      assert_filtering_works :operatingsystem, operatingsystems(:redhat).to_param
    end
  end

  context 'permissions' do
    test 'user with permissions to view host can also view its parameters' do
      setup_user 'view', 'params'
      setup_user 'view', 'hosts', "name = #{@host.name}"
      get :index, params: { :host_id => @host.name }, session: set_session_user(:one)
      assert_response :success
    end

    test 'user without permissions to view host cannot view parameters' do
      setup_user 'view', 'params'
      setup_user 'view', 'hosts', "name = some.other.host"
      get :index, params: { :host_id => @host.name }, session: set_session_user(:one)
      assert_response :not_found
    end
  end

  context 'hidden' do
    test "should show a host parameter as hidden unless show_hidden is true" do
      parameter = FactoryBot.create(:host_parameter, :host => @host, :hidden_value => true)
      get :show, params: { :host_id => @host.to_param, :id => parameter.to_param }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.hidden_value, show_response['value']
    end

    test "should show a host parameter unhidden when show_hidden is true" do
      parameter = FactoryBot.create(:host_parameter, :host => @host, :hidden_value => true)
      setup_user 'view', 'params'
      setup_user 'edit', 'params'
      setup_user 'view', 'hosts', "name = #{@host.name}"
      get :show, params: { :host_id => @host.to_param, :id => parameter.to_param, :show_hidden => 'true' }, session: set_session_user(:one)
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.value, show_response['value']
    end

    test "should show a host parameter as hidden even when show_hidden is true if user is not authorized" do
      parameter = FactoryBot.create(:host_parameter, :host => @host, :hidden_value => true)
      setup_user 'view', 'params'
      setup_user 'view', 'hosts', "name = #{@host.name}"
      get :show, params: { :host_id => @host.to_param, :id => parameter.to_param, :show_hidden => 'true' }, session: set_session_user(:one)
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameter.hidden_value, show_response['value']
    end
  end
end
