require 'test_helper'

class ProvisioningTemplatesControllerTest < ActionController::TestCase
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  test "index" do
    get :index, session: set_session_user
    assert_template 'index'
  end

  test "new" do
    get :new, session: set_session_user
    assert_template 'new'
  end

  test "create invalid" do
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :provisioning_template => {:name => "123"} }, session: set_session_user
    assert_template 'new'
  end

  test "create valid" do
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(true)
    post :create, params: { :provisioning_template => {:name => "123"} }, session: set_session_user
    assert_redirected_to provisioning_templates_url
  end

  test "edit" do
    get :edit, params: { :id => templates(:pxekickstart).to_param }, session: set_session_user
    assert_template 'edit'
  end

  test "edit page contains help information" do
    Setting[:safemode_render] = true
    get :edit, params: { :id => templates(:pxekickstart).to_param }, session: set_session_user
    assert_includes @response.body, Foreman::Renderer.config.allowed_helpers.first.to_s
    assert_includes @response.body, Foreman::Renderer.config.allowed_variables.first.to_s
    assert_includes @response.body, 'foreman_server_fqdn'
  end

  test "lock" do
    @request.env['HTTP_REFERER'] = provisioning_templates_path
    get :lock, params: { :id => templates(:pxekickstart).to_param }, session: set_session_user
    assert_redirected_to provisioning_templates_path
    assert_equal ProvisioningTemplate.unscoped.find(templates(:pxekickstart).id).locked, true
  end

  test "unlock" do
    @request.env['HTTP_REFERER'] = provisioning_templates_path
    get :unlock, params: { :id => templates(:locked).to_param }, session: set_session_user
    assert_redirected_to provisioning_templates_path
    assert_equal ProvisioningTemplate.unscoped.find(templates(:locked).id).locked, false
  end

  test "clone" do
    get :clone_template, params: { :id => templates(:pxekickstart).to_param }, session: set_session_user
    assert_template 'new'
  end

  test "export" do
    get :export, params: { :id => templates(:pxekickstart).to_param }, session: set_session_user
    assert_response :success
    assert_equal 'text/plain', response.media_type
    assert_equal templates(:pxekickstart).to_erb, response.body
    assert_match /attachment; filename="centos5_3_pxelinux.erb"/, response.headers['Content-Disposition']
  end

  test "update invalid" do
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => templates(:pxekickstart).to_param, :provisioning_template => {:name => "123"} }, session: set_session_user
    assert_template 'edit'
  end

  test "update valid" do
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => templates(:pxekickstart).to_param, :provisioning_template => {:name => "123"} }, session: set_session_user
    assert_redirected_to provisioning_templates_url
  end

  test "destroy should fail with assoicated hosts" do
    provisioning_template = templates(:pxekickstart)
    delete :destroy, params: { :id => provisioning_template.to_param }, session: set_session_user
    assert_redirected_to provisioning_templates_url
    assert ProvisioningTemplate.unscoped.exists?(provisioning_template.id)
  end

  test "destroy" do
    provisioning_template = templates(:pxekickstart)
    provisioning_template.os_default_templates.clear
    delete :destroy, params: { :id => provisioning_template.to_param }, session: set_session_user
    assert_redirected_to provisioning_templates_url
    assert !ProvisioningTemplate.unscoped.exists?(provisioning_template.id)
  end

  test "audit comment" do
    ProvisioningTemplate.auditing_enabled = true
    ProvisioningTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => templates(:pxekickstart).to_param, :provisioning_template => {:audit_comment => "aha", :template => "tmp" } }, session: set_session_user
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
    get :edit, params: { :id => template.to_param }, session: set_session_user

    assert @response.body.match('audit-content')
  end

  context 'PXE menu' do
    setup do
      TemplateKind::PXE.each do |kind|
        next if kind == 'iPXE'
        ["chainload", "discovery"].each do |snippet_type|
          snippet = File.read(File.expand_path(File.dirname(__FILE__) + "/../../app/views/unattended/provisioning_templates/snippet/#{kind.downcase}_#{snippet_type}.erb"))
          ProvisioningTemplate.create!(:name => "#{kind.downcase}_#{snippet_type}", :template => snippet, :snippet => true)
        end

        template = File.read(File.expand_path(File.dirname(__FILE__) + "/../../app/views/unattended/provisioning_templates/#{kind}/#{kind.downcase}_global_default.erb"))
        template_kind = TemplateKind.find_by :name => kind
        ProvisioningTemplate.find_or_create_by(:name => "#{kind} global default").update(:template => template, :template_kind => template_kind)
      end
      mac = File.read(File.expand_path(File.dirname(__FILE__) + "/../../app/views/unattended/provisioning_templates/snippet/pxegrub2_mac.erb"))
      ProvisioningTemplate.create!(:name => "pxegrub2_mac", :template => mac, :snippet => true)

      ProxyAPI::TFTP.any_instance.stubs(:fetch_boot_file).returns(true)
      Setting[:unattended_url] = "http://foreman.unattended.url"
      @request.env['HTTP_REFERER'] = provisioning_templates_path
    end

    test "build menu" do
      ProxyAPI::TFTP.any_instance.expects(:create_default).with(regexp_matches(/^PXE.*/), has_entry(:menu, regexp_matches(/ks=http:\/\/foreman.unattended.url\/unattended\/template/))).returns(true).times(3)
      get :build_pxe_default, session: set_session_user
      assert flash[:success].present?
      assert flash[:error].empty?
      assert_redirected_to provisioning_templates_path
    end

    test "build menu should return with error code if no TFTP defined" do
      SmartProxy.stubs(:with_features).with('TFTP').returns([])
      get :build_pxe_default, session: set_session_user
      assert flash[:error].present?
    end

    test "pxe menu's labels should be sorted" do
      t1 = TemplateCombination.new :hostgroup => hostgroups(:db)
      t1.provisioning_template = templates(:mystring2)
      t2 = TemplateCombination.new :hostgroup => hostgroups(:common)
      t2.provisioning_template = templates(:mystring2)
      t1.save
      t2.save
      ProxyAPI::TFTP.any_instance.expects(:create_default).with(regexp_matches(/^PXE.*/), has_entry(:menu, regexp_matches(/#{hostgroups(:common).name}.*#{hostgroups(:db).name}/m))).returns(true).times(3)
      get :build_pxe_default, session: set_session_user
      assert_redirected_to provisioning_templates_path
    end

    test "kickstart url should support in nested hostgroup " do
      t1 = TemplateCombination.new :hostgroup => hostgroups(:inherited)
      t1.provisioning_template = templates(:mystring2)
      t1.save
      ProxyAPI::TFTP.any_instance.expects(:create_default).with(regexp_matches(/^PXE.*/), has_entry(:menu, regexp_matches(/ks=http:\/\/foreman.unattended.url\/unattended\/template\/MyString2\/Parent\/inherited/))).returns(true).times(3)
      get :build_pxe_default, session: set_session_user
      assert_redirected_to provisioning_templates_path
    end

    test "pxe menu's labels should be sorted by full hostgroup title" do
      first = FactoryBot.build(:hostgroup, :parent => FactoryBot.create(:hostgroup, :name => "parent1"), :name => "def", :operatingsystem => operatingsystems(:centos5_3), :architecture => architectures(:x86_64), :medium => media(:one))
      second = FactoryBot.build(:hostgroup, :parent => FactoryBot.create(:hostgroup, :name => "parent2"), :name => "abc", :operatingsystem => operatingsystems(:centos5_3), :architecture => architectures(:x86_64), :medium => media(:one))
      FactoryBot.create(:template_combination, :provisioning_template => templates(:mystring2), :hostgroup => second)
      FactoryBot.create(:template_combination, :provisioning_template => templates(:mystring2), :hostgroup => first)
      ProxyAPI::TFTP.any_instance.expects(:create_default).with(regexp_matches(/^PXE.*/), has_entry(:menu, regexp_matches(/#{first.name}.*#{second.name}/m))).returns(true).times(3)
      get :build_pxe_default, session: set_session_user
      assert_redirected_to provisioning_templates_path
    end

    test "pxe menu build calls media with hostgroup" do
      hg = FactoryBot.build(:hostgroup, :name => "hg", :operatingsystem => operatingsystems(:centos5_3), :architecture => architectures(:x86_64), :medium => media(:one))
      FactoryBot.create(:template_combination, :provisioning_template => templates(:mystring2), :hostgroup => hg)
      ProxyAPI::TFTP.any_instance.stubs(:create_default).returns(true)
      Redhat.any_instance.expects(:pxe_files) do |_medium_provider, _arch, host|
        host.name == "hg"
      end.at_least(1)
      get :build_pxe_default, session: set_session_user
      assert_redirected_to provisioning_templates_path
    end
  end

  test 'preview' do
    host = FactoryBot.create(:host, :managed, :operatingsystem => FactoryBot.create(:suse, :with_archs, :with_media))
    template = FactoryBot.create(:provisioning_template)

    # works for given host
    post :preview, params: { :preview_host_id => host.id, :template => '<%= @host.name -%>', :id => template }, session: set_session_user
    assert_equal host.hostname.to_s.to_json, @response.body

    # without host specified it uses first one
    post :preview, params: { :template => '<%= 1+1 -%>', :id => template }, session: set_session_user
    assert_equal '2'.to_json, @response.body

    post :preview, params: { :template => '<%= 1+1 -%>' }, session: set_session_user
    assert_equal '2'.to_json, @response.body

    post :preview, params: { :template => '<%= 1+ -%>', :id => template }, session: set_session_user
    assert_includes @response.body, 'parse error on value'
  end

  test 'preview - registration' do
    template = FactoryBot.create(:provisioning_template, template_kind: template_kinds(:registration))

    post :preview, params: { :template => '<%= 1+1 -%>', :id => template }, session: set_session_user
    assert_equal '2'.to_json, @response.body
  end

  test 'preview - host_init_config' do
    template = FactoryBot.create(:provisioning_template, template_kind: template_kinds(:host_init_config))
    host = FactoryBot.create(:host, managed: false)

    # works for given host
    post :preview, params: { :preview_host_id => host.id, :template => '<%= @host.name -%>', :id => template }, session: set_session_user
    assert_equal host.hostname.to_s.to_json, @response.body

    # without host specified it uses first one
    post :preview, params: { :template => '<%= 1+1 -%>', :id => template }, session: set_session_user
    assert_equal '2'.to_json, @response.body
  end

  context 'templates combinations' do
    test 'can be added on template creation' do
      provisioning_template = {
        :name => 'foo',
        :template => '#nocontent',
        :template_kind_id => TemplateKind.find_by_name('iPXE').id,
        :template_combinations_attributes => { '3923' => { :hostgroup_id => hostgroups(:db).id } },
      }
      assert_difference('TemplateCombination.unscoped.count', 1) do
        assert_difference('ProvisioningTemplate.unscoped.count', 1) do
          post :create, params: {
            :provisioning_template => provisioning_template,
          }, session: set_session_user
        end
      end
    end

    context 'for already existing templates' do
      let(:template_combination) { FactoryBot.create(:template_combination) }

      test 'can be edited' do
        template = template_combination.provisioning_template
        new_hostgroup = FactoryBot.create(:hostgroup)
        assert_not_equal new_hostgroup, template_combination.hostgroup
        put :update, params: {
          :id => template.to_param,
          :provisioning_template => {
            :template_combinations_attributes => {
              '0' => {
                :id => template_combination.id,
                :hostgroup_id => new_hostgroup.id,
              },
            },
          },
        }, session: set_session_user
        assert_response :found
        as_admin do
          template_combination.reload
          assert_equal new_hostgroup, template_combination.hostgroup
        end
      end

      test 'can be destroyed' do
        template_combination
        assert_difference('TemplateCombination.count', -1) do
          put :update, params: {
            :id => template_combination.provisioning_template.to_param,
            :provisioning_template => {
              :template_combinations_attributes => {
                '0' => {
                  :id => template_combination.id,
                  :_destroy => 1,
                },
              },
            },
          }, session: set_session_user
        end
        assert_response :found
      end
    end
  end
end
