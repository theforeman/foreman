require 'test_helper'

class Api::V2::OperatingsystemsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:operatingsystems)
  end

  test "should show os" do
    get :show, params: { :id => operatingsystems(:redhat).to_param }
    assert_response :success
    assert_not_nil assigns(:operatingsystem)
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create os" do
    assert_difference('Operatingsystem.count') do
      post :create, params: { :operatingsystem => os_params }
    end
    assert_response :created
    assert_not_nil assigns(:operatingsystem)
  end

  test "should create os with os parameters" do
    os_with_params = os_params.merge(:os_parameters_attributes => {'0'=>{:name => "foo", :value => "bar"}})
    assert_difference('OsParameter.count') do
      assert_difference('Operatingsystem.count') do
        post :create, params: { :operatingsystem => os_with_params }
      end
    end
    assert_response :created
    assert_not_nil assigns(:operatingsystem)
  end

  test "should not create os without version" do
    assert_difference('Operatingsystem.count', 0) do
      post :create, params: { :operatingsystem => os_params.except(:major) }
    end
    assert_response :unprocessable_entity
  end

  test "should update os" do
    put :update, params: { :id => operatingsystems(:redhat).to_param, :operatingsystem => { :name => "new_name" } }
    assert_response :success
  end

  test "should destroy os" do
    assert_difference('Operatingsystem.count', -1) do
      delete :destroy, params: { :id => operatingsystems(:no_hosts_os).to_param }
    end
    assert_response :success
  end

  test "should update associated architectures by ids with UNWRAPPED node" do
    os = operatingsystems(:redhat)
    assert_difference('os.architectures.count') do
      put :update, params: { :id => os.to_param, :operatingsystem => { },
                             :architectures => [{ :id => architectures(:x86_64).id }, { :id => architectures(:sparc).id } ] }
    end
    assert_response :success
  end

  test "should update associated architectures by name with UNWRAPPED node" do
    os = operatingsystems(:redhat)
    assert_difference('os.architectures.count') do
      put :update, params: { :id => os.to_param, :operatingsystem => { },
                             :architectures => [{ :name => architectures(:x86_64).name }, { :name => architectures(:sparc).name } ] }
    end
    assert_response :success
  end

  test "should add association of architectures by ids with WRAPPED node" do
    os = operatingsystems(:redhat)
    assert_difference('os.architectures.count') do
      put :update, params: { :id => os.to_param, :operatingsystem => { :architectures => [{ :id => architectures(:x86_64).id }, { :id => architectures(:sparc).id }] } }
    end
    assert_response :success
  end

  test "should add association of architectures by name with WRAPPED node" do
    os = operatingsystems(:redhat)
    assert_difference('os.architectures.count') do
      put :update, params: { :id => os.to_param, :operatingsystem => { :architectures => [{ :name => architectures(:x86_64).name }, { :name => architectures(:sparc).name }] } }
    end
    assert_response :success
  end

  test "should remove association of architectures with WRAPPED node" do
    os = operatingsystems(:redhat)
    assert_difference('os.architectures.count', -1) do
      put :update, params: { :id => os.to_param, :operatingsystem => {:architectures => [] } }
    end
    assert_response :success
  end

  test "should show os if id is fullname" do
    get :show, params: { :id => operatingsystems(:centos5_3).fullname }
    assert_response :success
    assert_equal operatingsystems(:centos5_3), assigns(:operatingsystem)
  end

  test "should show os if id is description" do
    get :show, params: { :id => operatingsystems(:redhat).description }
    assert_response :success
    assert_equal operatingsystems(:redhat), assigns(:operatingsystem)
  end

  test "user without view_params permission can't see os parameters" do
    os_with_parameter = FactoryBot.create(:operatingsystem, :with_parameter)
    setup_user "view", "operatingsystems"
    get :show, params: { :id => os_with_parameter.to_param, :format => 'json' }
    assert_empty JSON.parse(response.body)['parameters']
  end

  test "user with view_params permission can see os parameters" do
    os_with_parameter = FactoryBot.create(:operatingsystem, :with_parameter)
    setup_user "view", "operatingsystems"
    setup_user "view", "params"
    get :show, params: { :id => os_with_parameter.to_param, :format => 'json' }
    assert_not_empty JSON.parse(response.body)['parameters']
  end

  context 'hidden parameters' do
    test "should show a os parameter as hidden unless show_hidden_parameters is true" do
      os = FactoryBot.create(:operatingsystem)
      os.os_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, params: { :id => os.id }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal '*****', show_response['parameters'].first['value']
    end

    test "should show a os parameter as unhidden when show_hidden_parameters is true" do
      os = FactoryBot.create(:operatingsystem)
      os.os_parameters.create!(:name => "foo", :value => "bar", :hidden_value => true)
      get :show, params: { :id => os.id, :show_hidden_parameters => 'true' }
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal 'bar', show_response['parameters'].first['value']
    end
  end

  test "should update existing operatingsystem parameters" do
    operatingsystem = FactoryBot.create(:operatingsystem)
    param_params = { :name => "foo", :value => "bar" }
    operatingsystem.os_parameters.create!(param_params)
    put :update, params: { :id => operatingsystem.id, :operatingsystem => { :os_parameters_attributes => [{ :name => param_params[:name], :value => "new_value" }] } }
    assert_response :success
    assert param_params[:name], operatingsystem.parameters.first.name
  end

  test "should delete existing os parameters" do
    operatingsystem = FactoryBot.create(:operatingsystem)
    param_1 = { :name => "foo", :value => "bar" }
    param_2 = { :name => "boo", :value => "test" }
    operatingsystem.os_parameters.create!([param_1, param_2])
    put :update, params: { :id => operatingsystem.id, :operatingsystem => { :os_parameters_attributes => [{ :name => param_1[:name], :value => "new_value" }] } }
    assert_response :success
    assert_equal 1, operatingsystem.parameters.count
  end

  private

  def os_params
    {
      :name  => "awsome_os",
      :major => "1",
      :minor => "2"
    }
  end
end
