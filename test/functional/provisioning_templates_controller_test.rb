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

  test "edit page contains help information" do
    Setting[:safemode_render] = true
    get :edit, {:id => templates(:pxekickstart).to_param}, set_session_user
    assert_includes @response.body, Foreman::Renderer::ALLOWED_HELPERS.first.to_s
    assert_includes @response.body, Foreman::Renderer::ALLOWED_VARIABLES.first.to_s
    assert_includes @response.body, 'foreman_server_fqdn'
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

  context 'PXE menu' do
    setup do
      TemplateKind::PXE.each do |kind|
        ["chainload", "discovery"].each do |snippet_type|
          snippet = File.read(File.expand_path(File.dirname(__FILE__) + "/../../app/views/unattended/snippets/_#{kind.downcase}_#{snippet_type}.erb"))
          ProvisioningTemplate.create!(:name => "#{kind.downcase}_#{snippet_type}", :template => snippet, :snippet => true)
        end
        template = File.read(File.expand_path(File.dirname(__FILE__) + "/../../app/views/unattended/pxe/#{kind}_default.erb"))
        ProvisioningTemplate.find_or_create_by(:name => "#{kind} global default").update_attribute(:template, template)
      end
      ProxyAPI::TFTP.any_instance.stubs(:fetch_boot_file).returns(true)
      Setting[:unattended_url] = "http://foreman.unattended.url"
      @request.env['HTTP_REFERER'] = provisioning_templates_path
    end

    test "build menu" do
      ProxyAPI::TFTP.any_instance.expects(:create_default).with(regexp_matches(/^PXE.*/), has_entry(:menu, regexp_matches(/ks=http:\/\/foreman.unattended.url\/unattended\/template/))).returns(true).times(3)
      get :build_pxe_default, {}, set_session_user
      assert_redirected_to provisioning_templates_path
    end

    test "pxe menu's labels should be sorted" do
      t1 = TemplateCombination.new :hostgroup => hostgroups(:db), :environment => environments(:production)
      t1.provisioning_template = templates(:mystring2)
      t2 = TemplateCombination.new :hostgroup => hostgroups(:common), :environment => environments(:production)
      t2.provisioning_template = templates(:mystring2)
      t1.save
      t2.save
      ProxyAPI::TFTP.any_instance.expects(:create_default).with(regexp_matches(/^PXE.*/), has_entry(:menu, regexp_matches(/#{hostgroups(:common).name}.*#{hostgroups(:db).name}/m))).returns(true).times(3)
      get :build_pxe_default, {}, set_session_user
      assert_redirected_to provisioning_templates_path
    end

    test "kickstart url should support in nested hostgroup " do
      t1 = TemplateCombination.new :hostgroup => hostgroups(:inherited), :environment => environments(:production)
      t1.provisioning_template = templates(:mystring2)
      t1.save
      ProxyAPI::TFTP.any_instance.expects(:create_default).with(regexp_matches(/^PXE.*/), has_entry(:menu, regexp_matches(/ks=http:\/\/foreman.unattended.url\/unattended\/template\/MyString2\/Parent\/inherited/))).returns(true).times(3)
      get :build_pxe_default, {}, set_session_user
      assert_redirected_to provisioning_templates_path
    end
  end

  test 'preview' do
    host = FactoryGirl.create(:host, :managed, :operatingsystem => FactoryGirl.create(:suse, :with_archs, :with_media))
    template = FactoryGirl.create(:provisioning_template)

    # works for given host
    post :preview, { :preview_host_id => host.id, :template => '<%= @host.name -%>', :id => template }, set_session_user
    assert_equal (host.hostname).to_s, @response.body

    # without host specified it uses first one
    post :preview, { :template => '<%= 1+1 -%>', :id => template }, set_session_user
    assert_equal '2', @response.body

    post :preview, { :template => '<%= 1+1 -%>'}, set_session_user
    assert_equal '2', @response.body

    post :preview, { :template => '<%= 1+ -%>', :id => template }, set_session_user
    assert_includes @response.body, 'There was an error'
  end

  context 'templates combinations' do
    test 'can be added on template creation' do
      template_combination = { :environment_id => environments(:production).id,
                               :hostgroup_id => hostgroups(:db).id }
      provisioning_template = {
        :name => 'foo',
        :template => '#nocontent',
        :template_kind_id => TemplateKind.find_by_name('iPXE').id,
        :template_combinations_attributes => { '3923' => template_combination }
      }
      assert_difference('TemplateCombination.count', 1) do
        assert_difference('ProvisioningTemplate.count', 1) do
          post :create, {
            :provisioning_template => provisioning_template
          }, set_session_user
        end
      end
    end

    context 'for already existing templates' do
      setup do
        @template_combination = FactoryGirl.create(:template_combination)
      end

      test 'can be edited' do
        template = @template_combination.provisioning_template
        new_environment = FactoryGirl.create(:environment)
        assert_not_equal new_environment, @template_combination.environment
        put :update, {
          :id => template.to_param,
          :provisioning_template => {
            :template_combinations_attributes => {
              '0' => {
                :id => @template_combination.id,
                :environment_id => new_environment.id,
                :hostgroup_id => @template_combination.hostgroup.id
              }
            }
          }
        }, set_session_user
        assert_response :found
        @template_combination.reload
        assert_equal new_environment, @template_combination.environment
      end

      test 'can be destroyed' do
        assert_difference('TemplateCombination.count', -1) do
          put :update, {
            :id => @template_combination.provisioning_template.to_param,
            :provisioning_template => {
              :template_combinations_attributes => {
                '0' => {
                  :id => @template_combination.id,
                  :_destroy => 1
                }
              }
            }
          }, set_session_user
        end
        assert_response :found
      end
    end
  end
end
