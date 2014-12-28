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
      post :create, {:operatingsystem => {:name => nil}}, set_session_user
      assert_template 'new'
    end

    test 'edit' do
      get :edit, {:id => Operatingsystem.first}, set_session_user
      assert_template 'edit'
    end

    test 'update invalid' do
      Operatingsystem.any_instance.stubs(:valid?).returns(false)
      Redhat.any_instance.stubs(:valid?).returns(false)
      put :update, {:id => Operatingsystem.first, :operatingsystem => {:name => Operatingsystem.first.name}}, set_session_user
      assert_template 'edit'
    end
  end

  context 'redirects' do
    test 'create valid' do
      Operatingsystem.any_instance.stubs(:valid?).returns(true)
      post :create, {:operatingsystem => {:name => "MyOS"}}, set_session_user
      assert_redirected_to operatingsystems_url
    end

    test 'update valid' do
      Operatingsystem.any_instance.stubs(:valid?).returns(true)
      Redhat.any_instance.stubs(:valid?).returns(true)
      put :update, {:id => Operatingsystem.first, :operatingsystem => {:name => "MyOS"}}, set_session_user
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

  context 'os_default_template' do
    setup do
      @template_kind = FactoryGirl.create(:template_kind)
      @config_template = FactoryGirl.create(:config_template, :template_kind_id => @template_kind.id)
    end

    test 'valid os_default_template should be saved' do
      operatingsystem = Operatingsystem.first
      put :update, {:id => operatingsystem.id, :operatingsystem =>
          {:os_default_templates_attributes => [{:config_template_id => @config_template.id, :template_kind_id => @template_kind.id} ]}}, set_session_user
      refute_empty operatingsystem.os_default_templates
      assert_redirected_to operatingsystems_url
    end

    test 'invalid os_default_template should be rejected' do
      operatingsystem = Operatingsystem.create({ :name => "PalmOS", :major => 1, :minor => 2 })
      put :update, {:id => operatingsystem.id,
                    :operatingsystem => {:os_default_templates_attributes => [{ :config_template_id => nil, :template_kind_id => @template_kind.id }]} }, set_session_user

      assert_empty operatingsystem.os_default_templates
    end

    test 'empty config_template should be destroyed' do
      operatingsystem = Operatingsystem.create({:name => "BESYS", :major => 3, :minor => 0,
                                                :os_default_templates_attributes => [{:config_template_id => @config_template.id, :template_kind_id => @template_kind.id}]})
      assert_difference 'OsDefaultTemplate.count', -1 do
        os_default_template_id = operatingsystem.os_default_templates.first.id
        put :update, {:id => operatingsystem.id,
                      :operatingsystem => {:os_default_templates_attributes => [{ :id => os_default_template_id, :config_template_id => '', :template_kind_id => @template_kind.id }] }}, set_session_user

      end
    end
  end
end
