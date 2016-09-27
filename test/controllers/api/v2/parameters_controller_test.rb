require 'test_helper'

class Api::V2::ParametersControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'special_key', :value => '123' }

  def setup
    @host = FactoryGirl.create(:host, :with_parameter)
    @host.lookup_value_matcher = @host.lookup_value_match
    @host.save
  end

  test "should get index for specific host" do
    get :index, {:host_id => @host.to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty parameters
  end

  test "should get index for specific domain" do
    get :index, {:domain_id => domains(:mydomain).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty parameters
  end

  test "should get index for specific hostgroup" do
    get :index, {:hostgroup_id => hostgroups(:common).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty parameters
  end

  test "should get index for specific os" do
    get :index, {:operatingsystem_id => operatingsystems(:redhat).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty parameters
  end

  test "should get index for specific location" do
    get :index, { :location_id => taxonomies(:location1).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty parameters
  end

  test "should get index for specific organization" do
    get :index, { :organization_id => taxonomies(:organization1).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty parameters
  end

  test "should show a host parameter" do
    get :show, { :host_id => @host.to_param, :id => @host.lookup_values.globals.first.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show a domain parameter" do
    get :show, {:domain_id => domains(:mydomain).to_param, :id => lookup_values(:domain).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show a hostgroup parameter" do
    get :show, {:hostgroup_id => hostgroups(:common).to_param,:id => lookup_values(:group).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show an os parameter" do
    get :show, {:operatingsystem_id => operatingsystems(:redhat).to_param,:id => lookup_values(:os).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show a location parameter" do
    get :show,  { :location_id => taxonomies(:location1).to_param, :id => lookup_values(:location).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show an organization parameter" do
    get :show,  { :organization_id => taxonomies(:organization1).to_param, :id => lookup_values(:org).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show a subnet parameter" do
    get :show, {:subnet_id => subnets(:five).to_param, :id => lookup_values(:subnet).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show correct parameter if id is name even if name is not unique" do
    # lookup_values(:os).name = 'os1' in fixtures
    # create DomainParamter with name name
    assert Domain.first.lookup_values.create(:key => 'os1')
    param = lookup_values(:os)
    get :show, {:operatingsystem_id => operatingsystems(:redhat).to_param,:id => param.key }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal param.id, show_response['id']
  end

  test "should create host parameter" do
    assert_difference('@host.lookup_values.globals.count') do
      post :create, { :host_id => @host.to_param, :parameter => valid_attrs }
    end
    assert_response :created
  end

  test "should create domain parameter" do
    domain = domains(:mydomain)
    assert_difference('domain.lookup_values.globals.count') do
      post :create, { :domain_id => domain.to_param, :parameter => valid_attrs }
    end
    assert_response :created
  end

  test "should create subnet parameter" do
    subnet = subnets(:five)
    assert_difference('subnet.lookup_values.globals.count') do
      post :create, { :subnet_id => subnet.to_param, :parameter => valid_attrs }
    end
    assert_response :created
  end

  test "should create hostgroup parameter" do
    hostgroup = hostgroups(:common)
    assert_difference('hostgroup.lookup_values.globals.count') do
      post :create, { :hostgroup_id => hostgroup.to_param, :parameter => valid_attrs }
    end
    assert_response :created
  end

  test "should create os parameter" do
    os = operatingsystems(:redhat)
    assert_difference('os.lookup_values.globals.count') do
      post :create, { :operatingsystem_id => os.to_param, :parameter => valid_attrs }
    end
    assert_response :created
  end

  test "should update nested host parameter" do
    put :update, { :host_id => @host.to_param, :id => @host.lookup_values.globals.first.to_param, :parameter => valid_attrs  }
    assert_response :success
    assert_equal '123', Host.find_by_name(@host.name).lookup_values.globals.order("lookup_values.updated_at").last.value
  end

  test "should update nested domain parameter" do
    put :update, { :domain_id => domains(:mydomain).to_param, :id => lookup_values(:domain).to_param, :parameter => valid_attrs  }
    assert_response :success
    assert_equal Domain.find_by_name("mydomain.net").lookup_values.globals.order("lookup_values.updated_at").last.value, "123"
  end

  test "should update nested subnet parameter" do
    put :update, { :subnet_id => subnets(:five).to_param, :id => lookup_values(:subnet).to_param, :parameter => valid_attrs }
    assert_response :success
    assert_equal Subnet.find_by_name("five").lookup_values.globals.order("lookup_values.updated_at").last.value, "123"
  end

  test "should update nested hostgroup parameter" do
    put :update, { :hostgroup_id => hostgroups(:common).to_param, :id => lookup_values(:group).to_param, :parameter => valid_attrs  }
    assert_response :success
    assert_equal Hostgroup.find_by_name("Common").lookup_values.globals.order("lookup_values.updated_at").last.value, "123"
  end

  test "should update nested os parameter" do
    put :update, { :operatingsystem_id => operatingsystems(:redhat).to_param, :id => lookup_values(:os).to_param, :parameter => valid_attrs  }
    assert_response :success
    assert_equal Operatingsystem.find_by_name("Redhat").lookup_values.globals.order("lookup_values.updated_at").last.value, "123"
  end

  test "should destroy nested host parameter" do
    host = @host
    param = FactoryGirl.create(:lookup_value, :with_key, :match => host.lookup_value_match)
    assert_difference('host.lookup_values.globals.count', -1) do
      delete :destroy, { :host_id => @host.to_param, :id => param.to_param }
    end
    assert_response :success
  end

  test "should destroy nested domain parameter" do
    domain =  domains(:mydomain)
    param = FactoryGirl.create(:lookup_value, :with_key, :match => domain.lookup_value_match)
    assert_difference('domain.lookup_values.globals.count', -1) do
      delete :destroy, { :domain_id =>domain.to_param, :id => param.to_param }
    end
    assert_response :success
  end

  test "should destroy nested subnet parameter" do
    assert_difference('LookupValue.count', -1) do
      delete :destroy, { :subnet_id => subnets(:five).to_param, :id => lookup_values(:subnet).to_param }
    end
    assert_response :success
  end

  test "should destroy Hostgroup parameter" do
    hg = hostgroups(:common)
    param = FactoryGirl.create(:lookup_value, :with_key, :match => hg.lookup_value_match)
    assert_difference('hg.lookup_values.globals.count', -1) do
      delete :destroy, { :hostgroup_id => hg.to_param, :id => param.to_param }
    end
    assert_response :success
  end

  test "should destroy nested os parameter" do
    os = operatingsystems(:redhat)
    param = FactoryGirl.create(:lookup_value, :with_key, :match => os.lookup_value_match)
    assert_difference('os.lookup_values.globals.count', -1) do
      delete :destroy, { :operatingsystem_id => os.to_param, :id => param.to_param }
    end
    assert_response :success
  end

  test "should reset nested host parameter" do
    assert_difference("@host.lookup_values.globals.count", -1) do
      delete :reset, { :host_id => @host.to_param }
    end
    assert_response :success
  end

  test "should reset nested domain parameter" do
    domain = domains(:mydomain)
    assert_difference('domain.lookup_values.globals.count', -1) do
      delete :reset, { :domain_id => domain.to_param }
    end
    assert_response :success
  end

  test "should reset nested subnet parameter" do
    assert_difference('LookupValue.count', -1) do
      delete :reset, { :subnet_id => subnets(:five).to_param }
    end
    assert_response :success
  end

  test "should reset Hostgroup parameter" do
    hg = FactoryGirl.create(:hostgroup)
    FactoryGirl.create(:lookup_value, :with_key, :match => hg.lookup_value_match)
    assert_difference('hg.lookup_values.globals.count', -1) do
      delete :reset, { :hostgroup_id => hg.to_param }
    end
    assert_response :success
  end

  test "should reset nested os parameters" do
    os =  operatingsystems(:redhat)
    assert_difference('os.lookup_values.globals.count', -1)  do
      delete :reset, { :operatingsystem_id => os.id }
    end
    assert_response :success
  end

  context "scoped search" do
    def assert_filtering_works(resource, id)
      post :create, { "#{resource}_id".to_sym => id, :parameter => { :name => 'my_param_2', :value => 'X' } }
      get :index, { "#{resource}_id".to_sym => id, :search => 'name = my_param_2' }
      assert_response :success
      assert_not_nil assigns(:parameters)
      parameters = ActiveSupport::JSON.decode(@response.body)
      assert_equal parameters['results'][0]['name'], 'my_param_2'
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
      get :index, { :host_id => @host.name }, set_session_user
      assert_response :success
    end

    test 'user without permissions to view host cannot view parameters' do
      setup_user 'view', 'params'
      setup_user 'view', 'hosts', "name = some.other.host"
      get :index, { :host_id => @host.name }, set_session_user
      assert_response :not_found
    end
  end
end
