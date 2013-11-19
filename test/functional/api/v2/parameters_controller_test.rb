require 'test_helper'

class Api::V2::ParametersControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'special_key', :value => '123' }

  test "should get index for specific system" do
    get :index, {:system_id => systems(:one).to_param }
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

  test "should get index for specific system_group" do
    get :index, {:system_group_id => system_groups(:common).to_param }
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

  test "should show a system parameter" do
    get :show, { :system_id => systems(:one).to_param, :id => parameters(:system).to_param }
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

  test "should show a system_group parameter" do
    get :show, {:system_group_id => system_groups(:common).to_param,:id => parameters(:group).to_param }
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

  test "should show correct parameter if id is name even if name is not unique" do
    # parameters(:os).name = 'os1' in fixtures
    # create DomainParamter with name name
    assert Domain.first.parameters.create(:name => 'os1')
    param = parameters(:os)
    get :show, {:operatingsystem_id => operatingsystems(:redhat).to_param,:id => param.name }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_equal param.id, show_response['parameter']['id']
  end

  test "should create system parameter" do
    system = systems(:one)
    assert_difference('system.parameters.count') do
      post :create, { :system_id => system.to_param, :parameter => valid_attrs }
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

  test "should create system_group parameter" do
    system_group = system_groups(:common)
    assert_difference('system_group.group_parameters.count') do
      post :create, { :system_group_id => system_group.to_param, :parameter => valid_attrs }
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

  test "should update nested system parameter" do
     put :update, { :system_id => systems(:one).to_param, :id => parameters(:system).to_param, :parameter => valid_attrs  }
     assert_response :success
     assert_equal System.find_by_name("my5name.mydomain.net").parameters.order("parameters.updated_at").last.value, "123"
  end

  test "should update nested domain parameter" do
     put :update, { :domain_id => domains(:mydomain).to_param, :id => parameters(:domain).to_param, :parameter => valid_attrs  }
     assert_response :success
     assert_equal Domain.find_by_name("mydomain.net").parameters.order("parameters.updated_at").last.value, "123"
  end

  test "should update nested system_group parameter" do
     put :update, { :system_group_id => system_groups(:common).to_param, :id => parameters(:group).to_param, :parameter => valid_attrs  }
     assert_response :success
     assert_equal SystemGroup.find_by_name("Common").group_parameters.order("parameters.updated_at").last.value, "123"
  end

  test "should update nested os parameter" do
     put :update, { :operatingsystem_id => operatingsystems(:redhat).to_param, :id => parameters(:os).to_param, :parameter => valid_attrs  }
     assert_response :success
     assert_equal Operatingsystem.find_by_name("Redhat").parameters.order("parameters.updated_at").last.value, "123"
  end

  test "should destroy nested system parameter" do
    assert_difference('SystemParameter.count', -1) do
      delete :destroy, { :system_id => systems(:one).to_param, :id => parameters(:system).to_param }
    end
    assert_response :success
  end

  test "should destroy nested domain parameter" do
    assert_difference('DomainParameter.count', -1) do
      delete :destroy, { :domain_id => domains(:mydomain).to_param, :id => parameters(:domain).to_param }
    end
    assert_response :success
  end

  test "should destroy SystemGroup parameter" do
    assert_difference('GroupParameter.count', -1) do
      delete :destroy, { :system_group_id => system_groups(:common).to_param, :id => parameters(:group).to_param }
    end
    assert_response :success
  end

  test "should destroy nested os parameter" do
    assert_difference('OsParameter.count', -1) do
      delete :destroy, { :operatingsystem_id => operatingsystems(:redhat).to_param, :id => parameters(:os).to_param }
    end
    assert_response :success
  end

  test "should reset nested system parameter" do
    assert_difference('SystemParameter.count', -1) do
      delete :reset, { :system_id => systems(:one).to_param }
    end
    assert_response :success
  end

  test "should reset nested domain parameter" do
    assert_difference('DomainParameter.count', -1) do
      delete :reset, { :domain_id => domains(:mydomain).to_param }
    end
    assert_response :success
  end

  test "should reset SystemGroup parameter" do
    assert_difference('GroupParameter.count', -1) do
      delete :reset, { :system_group_id => system_groups(:common).to_param }
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
