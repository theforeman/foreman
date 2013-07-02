require 'test_helper'

class OperatingsystemsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_index_json
    get :index, {:format => "json"}, set_session_user
    oses = ActiveSupport::JSON.decode(@response.body)
    assert !oses.empty?
    assert_response :success
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Operatingsystem.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Operatingsystem.any_instance.stubs(:valid?).returns(true)
    post :create, {}, set_session_user
    assert_redirected_to operatingsystems_url
  end

  def test_create_valid_json
    Operatingsystem.any_instance.stubs(:valid?).returns(true)
    post :create, {:format=> "json", :operatingsystem => {:name => "TestOs",
      :major => "1", :minor => "1"}}, set_session_user
    os = ActiveSupport::JSON.decode(@response.body)
    assert os["operatingsystem"]["name"] == "TestOs 1.1"
    assert_response :created
  end

  def test_edit
    get :edit, {:id => Operatingsystem.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Operatingsystem.any_instance.stubs(:valid?).returns(false)
    Redhat.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Operatingsystem.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Operatingsystem.any_instance.stubs(:valid?).returns(true)
    Redhat.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Operatingsystem.first}, set_session_user
    assert_redirected_to operatingsystems_url
  end

  def test_update_valid_json
    Operatingsystem.any_instance.stubs(:valid?).returns(true)
    Redhat.any_instance.stubs(:valid?).returns(true)
    put :update, {:format => "json", :id => Operatingsystem.first,
      :operatingsystem => {}}, set_session_user
    os = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
  end


  def test_destroy
    operatingsystem = Operatingsystem.first
    operatingsystem.hosts.delete_all
    operatingsystem.hostgroups.delete_all
    delete :destroy, {:id => operatingsystem}, set_session_user
    assert_redirected_to operatingsystems_url
    assert !Operatingsystem.exists?(operatingsystem.id)
  end

  def test_destroy_json
    operatingsystem = Operatingsystem.first
    operatingsystem.hosts.delete_all
    operatingsystem.hostgroups.delete_all
    delete :destroy, {:format => "json", :id => operatingsystem}, set_session_user
    os = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    assert !Operatingsystem.exists?(operatingsystem.id)
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit an operating system' do
    setup_user
    get :edit, {:id => Operatingsystem.first.id}, set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should succeed in viewing operatingsystems' do
    setup_user
    get :index, {}, set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end
end
