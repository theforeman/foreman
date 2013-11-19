require 'test_helper'

class Api::V1::SystemsControllerTest < ActionController::TestCase

  def valid_attrs
    { :name                => 'testsystem11',
      :environment_id      => environments(:production).id,
      :domain_id           => domains(:mydomain).id,
      :ip                  => '10.0.0.20',
      :mac                 => '52:53:00:1e:85:93',
      :architecture_id     => Architecture.find_by_name('x86_64').id,
      :operatingsystem_id  => Operatingsystem.find_by_name('Redhat').id,
      :puppet_proxy_id     => smart_proxies(:one).id,
      :compute_resource_id => compute_resources(:one).id
    }
  end

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:systems)
    systems = ActiveSupport::JSON.decode(@response.body)
    assert !systems.empty?
  end

  test "should show individual record" do
    get :show, { :id => systems(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create system" do
    disable_orchestration
    assert_difference('System.count') do
      post :create, { :system => valid_attrs }
    end
    assert_response :success
    last_system = System.order('id desc').last
  end

  test "should create system with managed is false if parameter is passed" do
    disable_orchestration
    post :create, { :system => valid_attrs.merge!(:managed => false) }
    assert_response :success
    last_system = System.order('id desc').last
    assert_equal false, last_system.managed?
  end

  test "should update system" do
    put :update, { :id => systems(:two).to_param, :system => { } }
    assert_response :success
  end

  test "should destroy systems" do
    assert_difference('System.count', -1) do
      delete :destroy, { :id => systems(:one).to_param }
    end
    assert_response :success
  end

  test "should show status systems" do
    get :status, { :id => systems(:one).to_param }
    assert_response :success
  end

  test "should be able to create systems even when restricted" do
    disable_orchestration
    assert_difference('System.count') do
      post :create, { :system => valid_attrs }
    end
    assert_response :success
  end

  test "should allow access to restricted user who owns the system" do
    as_user :restricted do
      get :show, { :id => systems(:owned_by_restricted).to_param }
    end
    assert_response :success
  end

  test "should allow to update for restricted user who owns the system" do
    disable_orchestration
    as_user :restricted do
      put :update, { :id => systems(:owned_by_restricted).to_param, :system => {} }
    end
    assert_response :success
  end

  test "should allow destroy for restricted user who owns the systems" do
    assert_difference('System.count', -1) do
      as_user :restricted do
        delete :destroy, { :id => systems(:owned_by_restricted).to_param }
      end
    end
    assert_response :success
  end

  test "should allow show status for restricted user who owns the systems" do
    as_user :restricted do
      get :status, { :id => systems(:owned_by_restricted).to_param }
    end
    assert_response :success
  end

  test "should not allow access to a system out of users systems scope" do
    as_user :restricted do
      get :show, { :id => systems(:one).to_param }
    end
    assert_response :not_found
  end

  test "should not list a system out of users systems scope" do
    as_user :restricted do
      get :index, {}
    end
    assert_response :success
    systems = ActiveSupport::JSON.decode(@response.body)
    ids = systems.map { |hash| hash['system']['id'] }
    assert !ids.include?(systems(:one).id)
    assert ids.include?(systems(:owned_by_restricted).id)
  end

  test "should not update system out of users systems scope" do
    as_user :restricted do
      put :update, { :id => systems(:one).to_param }
    end
    assert_response :not_found
  end

  test "should not delete systems out of users systems scope" do
    as_user :restricted do
      delete :destroy, { :id => systems(:one).to_param }
    end
    assert_response :not_found
  end

  test "should not show status of systems out of users systems scope" do
    as_user :restricted do
      get :status, { :id => systems(:one).to_param }
    end
    assert_response :not_found
  end

  def set_remote_user_to user
    @request.env['REMOTE_USER'] = user.login
  end

  test "when REMOTE_USER is provided and both authorize_login_delegation{,_api}
        are set, authentication should succeed w/o valid session cookies" do
    Setting[:authorize_login_delegation] = true
    Setting[:authorize_login_delegation_api] = true
    set_remote_user_to users(:admin)
    User.current = nil # User.current is admin at this point (from initialize_system)
    system = System.first
    get :show, {:id => system.to_param, :format => 'json'}
    assert_response :success
    get :show, {:id => system.to_param}
    assert_response :success
  end

end
