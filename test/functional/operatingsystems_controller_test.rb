require 'test_helper'
class OperatingsystemsControllerTest < ActionController::TestCase

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  context 'template rendering' do
    test 'index' do
      get :index, {}, set_session_user
      assert_template 'index'
    end

    test 'new' do
      get :new, {}, set_session_user
      assert_template 'new'
    end

    test 'create invalid' do
      Operatingsystem.any_instance.stubs(:valid?).returns(false)
      post :create, {}, set_session_user
      assert_template 'new'
    end

    test 'edit' do
      get :edit, {:id => Operatingsystem.first}, set_session_user
      assert_template 'edit'
    end

    test 'update invalid' do
      Operatingsystem.any_instance.stubs(:valid?).returns(false)
      Redhat.any_instance.stubs(:valid?).returns(false)
      put :update, {:id => Operatingsystem.first}, set_session_user
      assert_template 'edit'
    end
  end

  context 'redirects' do
    test 'create valid' do
      Operatingsystem.any_instance.stubs(:valid?).returns(true)
      post :create, {}, set_session_user
      assert_redirected_to operatingsystems_url
    end

    test 'update valid' do
      Operatingsystem.any_instance.stubs(:valid?).returns(true)
      Redhat.any_instance.stubs(:valid?).returns(true)
      put :update, {:id => Operatingsystem.first}, set_session_user
      assert_redirected_to operatingsystems_url
    end

    test 'destroy' do
      operatingsystem = Operatingsystem.first
      operatingsystem.hosts.delete_all
      operatingsystem.hostgroups.delete_all
      delete :destroy, {:id => operatingsystem}, set_session_user
      assert_redirected_to operatingsystems_url
      assert !Operatingsystem.exists?(operatingsystem.id)
    end
  end

  context 'permission access' do
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

  context 'search' do
    test 'valid fields' do
      get :index, { :search => 'name = centos' }, set_session_user
      assert_response :success
      assert flash.empty?
    end

    test 'invalid fields' do
      @request.env['HTTP_REFERER'] = "http://test.host#{operatingsystems_path}"
      get :index, { :search => 'wrongwrong = centos' }, set_session_user
      assert_response :redirect
      assert_redirected_to :back
      assert_match /not recognized for searching/, flash[:error]
    end
  end
end
