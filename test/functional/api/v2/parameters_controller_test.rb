require 'test_helper'

class Api::V2::ParametersControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'special_key', :value => '123' }

  def setup
    @host = FactoryGirl.create(:host, :with_parameter)
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

  test "should show a host parameter" do
    get :show, { :host_id => @host.to_param, :id => @host.parameters.first.to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show a domain parameter" do
    get :show, {:domain_id => domains(:mydomain).to_param, :id => parameters(:domain).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show a hostgroup parameter" do
    get :show, {:hostgroup_id => hostgroups(:common).to_param,:id => parameters(:group).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show an os parameter" do
    get :show, {:operatingsystem_id => operatingsystems(:redhat).to_param,:id => parameters(:os).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not_empty show_response
  end

  test "should show correct parameter if id is name even if name is not unique" do
    # parameters(:os).name = 'os1' in fixtures
    # create DomainParamter with name name
    assert Domain.first.parameters.create(:name => 'os1')
    param = parameters(:os)
    get :show, {:operatingsystem_id => operatingsystems(:redhat).to_param,:id => param.name }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal param.id, show_response['id']
  end

  test "should create host parameter" do
    assert_difference('@host.parameters.count') do
      post :create, { :host_id => @host.to_param, :parameter => valid_attrs }
    end
    assert_response :success
  end

  test "should create domain parameter" do
    domain = domains(:mydomain)
    assert_difference('domain.parameters.count') do
      post :create, { :domain_id => domain.to_param, :parameter => valid_attrs }
    end
    assert_response :success
  end

  test "should create hostgroup parameter" do
    hostgroup = hostgroups(:common)
    assert_difference('hostgroup.group_parameters.count') do
      post :create, { :hostgroup_id => hostgroup.to_param, :parameter => valid_attrs }
    end
    assert_response :success
  end

  test "should create os parameter" do
    os = operatingsystems(:redhat)
    assert_difference('os.parameters.count') do
      post :create, { :operatingsystem_id => os.to_param, :parameter => valid_attrs }
    end
    assert_response :success
  end

  test "should update nested host parameter" do
    put :update, { :host_id => @host.to_param, :id => @host.parameters.first.to_param, :parameter => valid_attrs  }
    assert_response :success
    assert_equal '123', Host.find_by_name(@host.name).parameters.order("parameters.updated_at").last.value
  end

  test "should update nested domain parameter" do
    put :update, { :domain_id => domains(:mydomain).to_param, :id => parameters(:domain).to_param, :parameter => valid_attrs  }
    assert_response :success
    assert_equal Domain.find_by_name("mydomain.net").parameters.order("parameters.updated_at").last.value, "123"
  end

  test "should update nested hostgroup parameter" do
    put :update, { :hostgroup_id => hostgroups(:common).to_param, :id => parameters(:group).to_param, :parameter => valid_attrs  }
    assert_response :success
    assert_equal Hostgroup.find_by_name("Common").group_parameters.order("parameters.updated_at").last.value, "123"
  end

  test "should update nested os parameter" do
    put :update, { :operatingsystem_id => operatingsystems(:redhat).to_param, :id => parameters(:os).to_param, :parameter => valid_attrs  }
    assert_response :success
    assert_equal Operatingsystem.find_by_name("Redhat").parameters.order("parameters.updated_at").last.value, "123"
  end

  test "should destroy nested host parameter" do
    assert_difference('HostParameter.count', -1) do
      delete :destroy, { :host_id => @host.to_param, :id => @host.parameters.first.to_param }
    end
    assert_response :success
  end

  test "should destroy nested domain parameter" do
    assert_difference('DomainParameter.count', -1) do
      delete :destroy, { :domain_id => domains(:mydomain).to_param, :id => parameters(:domain).to_param }
    end
    assert_response :success
  end

  test "should destroy Hostgroup parameter" do
    assert_difference('GroupParameter.count', -1) do
      delete :destroy, { :hostgroup_id => hostgroups(:common).to_param, :id => parameters(:group).to_param }
    end
    assert_response :success
  end

  test "should destroy nested os parameter" do
    assert_difference('OsParameter.count', -1) do
      delete :destroy, { :operatingsystem_id => operatingsystems(:redhat).to_param, :id => parameters(:os).to_param }
    end
    assert_response :success
  end

  test "should reset nested host parameter" do
    assert_difference('HostParameter.count', -1) do
      delete :reset, { :host_id => @host.to_param }
    end
    assert_response :success
  end

  test "should reset nested domain parameter" do
    assert_difference('DomainParameter.count', -1) do
      delete :reset, { :domain_id => domains(:mydomain).to_param }
    end
    assert_response :success
  end

  test "should reset Hostgroup parameter" do
    assert_difference('GroupParameter.count', -1) do
      delete :reset, { :hostgroup_id => hostgroups(:common).to_param }
    end
    assert_response :success
  end

  test "should reset nested os parameters" do
    assert_difference('OsParameter.count', -1)  do
      delete :reset, { :operatingsystem_id => operatingsystems(:redhat).id }
    end
    assert_response :success
  end

  context "scoped search" do

    def assert_filtering_works(resource, id)
      post :create, { "#{resource}_id".to_sym => id, :parameter => { :name => 'parameter2', :value => 'X' } }
      get :index, { "#{resource}_id".to_sym => id, :search => 'name = parameter2' }
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

    test "should get index for specific hostgroup fitered by name" do
      assert_filtering_works :hostgroup, hostgroups(:common).to_param
    end

    test "should get index for specific os filtred by name" do
      assert_filtering_works :operatingsystem, operatingsystems(:redhat).to_param
    end

  end
end
