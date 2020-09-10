require 'test_helper'
require 'nokogiri'

class OperatingsystemsControllerTest < ActionController::TestCase
  setup do
    @factory_options = :with_parameter
  end

  basic_pagination_rendered_test
  basic_pagination_per_page_test

  def setup_os_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.default, Role.find_by_name('Viewer')]
  end

  context 'template rendering' do
    test 'index' do
      get :index, session: set_session_user
      assert_template 'index'
    end

    test 'new' do
      get :new, session: set_session_user
      assert_template 'new'
    end

    test 'create invalid' do
      Operatingsystem.any_instance.stubs(:valid?).returns(false)
      post :create, params: { :operatingsystem => {:name => nil} }, session: set_session_user
      assert_template 'new'
    end

    test 'edit' do
      get :edit, params: { :id => Operatingsystem.first }, session: set_session_user
      assert_template 'edit'
    end

    test 'update invalid' do
      Operatingsystem.any_instance.stubs(:valid?).returns(false)
      Redhat.any_instance.stubs(:valid?).returns(false)
      put :update, params: { :id => Operatingsystem.first, :operatingsystem => {:name => Operatingsystem.first.name} }, session: set_session_user
      assert_template 'edit'
    end
  end

  context 'redirects' do
    test 'create valid' do
      Operatingsystem.any_instance.stubs(:valid?).returns(true)
      post :create, params: { :operatingsystem => {:name => "MyOS"} }, session: set_session_user
      assert_redirected_to operatingsystems_url
    end

    test 'update valid' do
      Operatingsystem.any_instance.stubs(:valid?).returns(true)
      Redhat.any_instance.stubs(:valid?).returns(true)
      put :update, params: { :id => Operatingsystem.first, :operatingsystem => {:name => "MyOS"} }, session: set_session_user
      assert_redirected_to operatingsystems_url
    end

    test 'destroy' do
      operatingsystem = Operatingsystem.first
      operatingsystem.hosts.delete_all
      operatingsystem.hostgroups.delete_all
      delete :destroy, params: { :id => operatingsystem }, session: set_session_user
      assert_redirected_to operatingsystems_url
      assert !Operatingsystem.exists?(operatingsystem.id)
    end
  end

  context 'permission access' do
    test 'user with viewer rights should fail to edit an operating system' do
      setup_os_user
      get :edit, params: { :id => Operatingsystem.first.id }, session: set_session_user.merge(:user => users(:one).id)
      assert_equal @response.status, 403
    end

    test 'user with viewer rights should succeed in viewing operatingsystems' do
      setup_os_user
      get :index, session: set_session_user.merge(:user => users(:one).id)
      assert_response :success
    end

    test 'user with view_params rights should see parameters in an os' do
      os = FactoryBot.create(:operatingsystem, :with_parameter)
      setup_user "edit", "operatingsystems"
      setup_user "view", "params"
      get :edit, params: { :id => os.id }, session: set_session_user.merge(:user => users(:one).id)
      html_doc = Nokogiri::HTML(response.body)
      assert_not_empty html_doc.css('table#global_parameters_table')
    end

    test 'user without view_params rights should not see parameters in an os' do
      os = FactoryBot.create(:operatingsystem, :with_parameter)
      setup_user "edit", "operatingsystems"
      get :edit, params: { :id => os.id }, session: set_session_user.merge(:user => users(:one).id)
      html_doc = Nokogiri::HTML(response.body)
      assert_empty html_doc.css('table#global_parameters_table')
    end
  end

  context 'search' do
    test 'valid fields' do
      get :index, params: { :search => 'name = centos' }, session: set_session_user
      assert_response :success
      assert flash.empty?
    end

    test 'invalid fields' do
      @request.env['HTTP_REFERER'] = "http://test.host#{operatingsystems_path}"
      get :index, params: { :search => 'wrongwrong = centos' }, session: set_session_user
      assert_response :redirect
      assert_redirected_to operatingsystems_path
      assert_match /not recognized for searching/, flash[:error]
    end
  end

  context 'os_default_template' do
    setup do
      @template_kind = FactoryBot.create(:template_kind)
      @provisioning_template = FactoryBot.create(:provisioning_template, :template_kind_id => @template_kind.id)
    end

    test 'valid os_default_template should be saved' do
      operatingsystem = Operatingsystem.first
      put :update, params: { :id => operatingsystem.id, :operatingsystem =>
          {:os_default_templates_attributes => [{:provisioning_template_id => @provisioning_template.id, :template_kind_id => @template_kind.id}]} }, session: set_session_user
      refute_empty operatingsystem.os_default_templates
      assert_redirected_to operatingsystems_url
    end

    test 'invalid os_default_template should be rejected' do
      operatingsystem = Operatingsystem.create({ :name => "PalmOS", :major => 1, :minor => 2 })
      put :update, params: { :id => operatingsystem.id,
                             :operatingsystem => {:os_default_templates_attributes => [{ :provisioning_template_id => nil, :template_kind_id => @template_kind.id }]} }, session: set_session_user

      assert_empty operatingsystem.os_default_templates
    end

    test 'empty provisioning_template should be destroyed' do
      operatingsystem = Operatingsystem.create({:name => "BESYS", :major => 3, :minor => 0,
                                                :os_default_templates_attributes => [{:provisioning_template_id => @provisioning_template.id, :template_kind_id => @template_kind.id}]})
      assert_difference 'OsDefaultTemplate.count', -1 do
        os_default_template_id = operatingsystem.os_default_templates.first.id
        put :update, params: { :id => operatingsystem.id,
                               :operatingsystem => {:os_default_templates_attributes => [{ :id => os_default_template_id, :provisioning_template_id => '', :template_kind_id => @template_kind.id }]} }, session: set_session_user
      end
    end
  end
end
