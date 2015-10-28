require 'test_helper'

class ProvisioningTemplatesControllerTest < ActionController::TestCase
  test "index" do
    get :index, {}, set_session_user
    assert_template 'index'
  end

  test "new" do
    get :new, {}, set_session_user
    assert_template 'new'
  end

  test "create invalid" do
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(false)
    post :create, {:provisioning_template => {:name => "123"}}, set_session_user
    assert_template 'new'
  end

  test "create valid" do
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(true)
    post :create, {:provisioning_template => {:name => "123"}}, set_session_user
    assert_redirected_to provisioning_templates_url
  end

  test "edit" do
    get :edit, {:id => templates(:pxekickstart).to_param}, set_session_user
    assert_template 'edit'
  end

  test "lock" do
    @request.env['HTTP_REFERER'] = provisioning_templates_path
    get :lock, {:id => templates(:pxekickstart).to_param }, set_session_user
    assert_redirected_to provisioning_templates_path
    assert_equal ProvisioningTemplate.find(templates(:pxekickstart).id).locked, true
  end

  test "unlock" do
    @request.env['HTTP_REFERER'] = provisioning_templates_path
    get :unlock, {:id => templates(:locked).to_param }, set_session_user
    assert_redirected_to provisioning_templates_path
    assert_equal ProvisioningTemplate.find(templates(:locked).id).locked, false
  end

  test "clone" do
    get :clone_template, {:id => templates(:pxekickstart).to_param }, set_session_user
    assert_template 'new'
  end

  test "update invalid" do
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => templates(:pxekickstart).to_param, :provisioning_template => {:name => "123"} }, set_session_user
    assert_template 'edit'
  end

  test "update valid" do
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => templates(:pxekickstart).to_param, :provisioning_template => {:name => "123"} }, set_session_user
    assert_redirected_to provisioning_templates_url
  end

  test "destroy should fail with assoicated hosts" do
    config_template = templates(:pxekickstart)
    delete :destroy, {:id => config_template.to_param }, set_session_user
    assert_redirected_to provisioning_templates_url
    assert ProvisioningTemplate.exists?(config_template.id)
  end

  test "destroy" do
    config_template = templates(:pxekickstart)
    config_template.os_default_templates.clear
    delete :destroy, {:id => config_template.to_param }, set_session_user
    assert_redirected_to provisioning_templates_url
    assert !ProvisioningTemplate.exists?(config_template.id)
  end

  test "audit comment" do
    ProvisioningTemplate.auditing_enabled = true
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => templates(:pxekickstart).to_param, :provisioning_template => {:audit_comment => "aha", :template => "tmp" } }, set_session_user
    assert_redirected_to provisioning_templates_url
    assert_equal "aha", templates(:pxekickstart).audits.last.comment
  end

  test "history in edit" do
    setup_users
    ProvisioningTemplate.auditing_enabled = true
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(true)
    template = templates(:pxekickstart)
    template.template = template.template.upcase
    assert template.save
    assert_equal template.audits.count, 1
    get :edit, {:id => template.to_param }, set_session_user

    assert @response.body.match('audit-content')
  end

  test "build menu" do
    template = File.read(File.expand_path(File.dirname(__FILE__) + "/../../app/views/unattended/pxe/PXELinux_default.erb"))
    ProvisioningTemplate.find_by_name('PXELinux global default').update_attribute(:template, template)

    ProxyAPI::TFTP.any_instance.stubs(:fetch_boot_file).returns(true)
    Setting[:unattended_url] = "http://foreman.unattended.url"
    @request.env['HTTP_REFERER'] = provisioning_templates_path

    ProxyAPI::TFTP.any_instance.expects(:create_default).with(has_entry(:menu, regexp_matches(/ks=http:\/\/foreman.unattended.url\/unattended\/template/))).returns(true)

    get :build_pxe_default, {}, set_session_user
    assert_redirected_to provisioning_templates_path
  end

  test 'preview' do
    host = FactoryGirl.create(:host, :managed, :operatingsystem => FactoryGirl.create(:suse, :with_archs))
    template = FactoryGirl.create(:provisioning_template)

    # works for given host
    post :preview, { :preview_host_id => host.id, :template => '<%= @host.name -%>', :id => template }, set_session_user
    assert_equal "#{host.hostname}", @response.body

    # without host specified it uses first one
    post :preview, { :template => '<%= 1+1 -%>', :id => template }, set_session_user
    assert_equal '2', @response.body

    post :preview, { :template => '<%= 1+ -%>', :id => template }, set_session_user
    assert_includes @response.body, 'There was an error'
  end
end
