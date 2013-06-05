require 'test_helper'

class Api::V2::ParametersControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'special_key', :value => '123' }

  test "should get index for specific host" do
    get :index, {:host_id => hosts(:one).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert !parameters.empty?
  end

  test "should get index for specific domain" do
    get :index, {:domain_id => domains(:mydomain).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert !parameters.empty?
  end

  test "should get index for specific hostgroup" do
    get :index, {:hostgroup_id => hostgroups(:common).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert !parameters.empty?
  end


  test "should get index for specific os" do
    get :index, {:operatingsystem_id => operatingsystems(:redhat).to_param }
    assert_response :success
    assert_not_nil assigns(:parameters)
    parameters = ActiveSupport::JSON.decode(@response.body)
    assert !parameters.empty?
  end

  test "should show a host parameter" do
    get :show, { :host_id => hosts(:one).to_param, :id => parameters(:host).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should show a domain parameter" do
    get :show, {:domain_id => domains(:mydomain).to_param, :id => parameters(:domain).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should show a hostgroup parameter" do
    get :show, {:hostgroup_id => hostgroups(:common).to_param,:id => parameters(:group).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should show an os parameter" do
    get :show, {:operatingsystem_id => operatingsystems(:redhat).to_param,:id => parameters(:os).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create host parameter" do
    host = hosts(:one)
    assert_difference('host.parameters.count') do
      post :create, { :host_id => host.to_param, :parameter => valid_attrs }
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
     put :update, { :host_id => hosts(:one).to_param, :id => parameters(:host).to_param, :parameter => valid_attrs  }
     assert_response :success
     assert_equal Host.find_by_name("my5name.mydomain.net").parameters.order("parameters.updated_at").last.value, "123"
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
      delete :destroy, { :host_id => hosts(:one).to_param, :id => parameters(:host).to_param }
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
      delete :reset, { :host_id => hosts(:one).to_param }
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
      delete :reset, { :operatingsystem_id => operatingsystems(:redhat).name }
    end
    assert_response :success
  end

end
