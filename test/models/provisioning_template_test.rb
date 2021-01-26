require 'test_helper'

class ProvisioningTemplateTest < ActiveSupport::TestCase
  should allow_values(*valid_name_list).for(:name)
  should_not allow_values(*invalid_name_list).for(:name)

  test "should be valid when selecting a kind" do
    tmplt               = ProvisioningTemplate.new
    tmplt.name          = "Default Kickstart"
    tmplt.template      = "Some kickstart goes here"
    tmplt.template_kind = template_kinds(:ipxe)
    assert tmplt.valid?
  end

  test "should be valid as a snippet" do
    tmplt          = ProvisioningTemplate.new
    tmplt.name     = "Default Kickstart"
    tmplt.template = "Some kickstart goes here"
    tmplt.snippet  = true
    assert tmplt.valid?
  end

  test "should be invalid" do
    assert !ProvisioningTemplate.new.valid?
  end

  test "should save assoications if not snippet" do
    tmplt = ProvisioningTemplate.new
    tmplt.name = "Some finish script"
    tmplt.template = "echo $HOME"
    tmplt.template_kind = template_kinds(:finish)
    tmplt.snippet = false # this is the default, but it helps show the case
    tmplt.hostgroups << hostgroups(:common)
    as_admin do
      assert tmplt.save
    end
    assert_equal template_kinds(:finish), tmplt.template_kind
    assert_equal [hostgroups(:common)], tmplt.hostgroups
  end

  test "should not save assoications if snippet" do
    tmplt          = ProvisioningTemplate.new
    tmplt.name     = "Default Kickstart"
    tmplt.template = "Some kickstart goes here"
    tmplt.snippet  = true
    tmplt.template_kind = template_kinds(:ipxe)
    tmplt.hostgroups << hostgroups(:common)
    as_admin do
      assert tmplt.save
    end
    assert_nil tmplt.template_kind
    assert_equal [], tmplt.hostgroups
    assert_equal [], tmplt.template_combinations
  end

  # If the template is not a snippet is should require the specific declaration
  # of a type (ipxe, finish, etc.)
  test "should require a template kind" do
    tmplt = ProvisioningTemplate.new
    tmplt.name = "Some finish script"
    tmplt.template = "echo $HOME"

    assert !tmplt.save
  end

  test "should be able to clone" do
    tmplt          = ProvisioningTemplate.new
    tmplt.name     = "Finish It"
    tmplt.template = "some content"
    tmplt.snippet  = false
    tmplt.template_kind = template_kinds(:finish)
    as_admin do
      assert tmplt.save
    end
    clone = tmplt.clone

    assert_nil clone.name
    assert_equal clone.operatingsystems, tmplt.operatingsystems
    assert_equal clone.template_kind_id, tmplt.template_kind_id
    assert_equal clone.template, tmplt.template
  end

  test "can instantiate a locked template" do
    assert FactoryBot.create(:provisioning_template, :locked => true)
  end

  context 'locked templates outside of rake' do
    setup do
      Foreman.stubs(:in_rake?).returns(false)
      @template = templates(:locked)
    end

    test "should not edit a locked template" do
      @template.name = "something else"
      refute_valid @template, :base, /is locked/
    end

    test "should not remove a locked template" do
      refute_with_errors @template.destroy, @template, :base, /locked/
    end

    test "should not unlock a template if not allowed" do
      User.current = FactoryBot.create(:user)
      @template.locked = false
      refute_valid @template, :base, /not authorized/
    end
  end

  test "should clone a locked template as unlocked" do
    tmplt = templates(:locked)
    clone = tmplt.clone
    assert_nil clone.name
    assert_equal clone.operatingsystems, tmplt.operatingsystems
    assert_equal clone.template_kind_id, tmplt.template_kind_id
    assert_equal clone.template, tmplt.template
    assert tmplt.locked
    refute clone.locked
  end

  test "locked template can be modified if it's being unlocked at the same time" do
    tmplt = templates(:locked)
    tmplt.template = 'new_content'
    tmplt.locked = false
    assert tmplt.valid?
  end

  test "unlocked template can be modified if it's being locked at the same time" do
    tmplt = templates(:mystring)
    tmplt.template = 'new_content'
    tmplt.locked = true
    assert tmplt.valid?
  end

  test "should change a locked template while in rake" do
    Foreman.stubs(:in_rake?).returns(true)
    tmplt = templates(:locked)
    tmplt.template = "changing the template content"
    tmplt.name = "giving it a new name too"
    assert tmplt.locked
    assert_valid tmplt
  end

  test '#preview_host_collection obeys view_hosts permission' do
    Host.expects(:authorized).with(:view_hosts).returns(Host.where(nil))
    ProvisioningTemplate.preview_host_collection
  end

  test 'saving removes carriage returns' do
    template = FactoryBot.build(:provisioning_template, template: "a\r\nb\r\nc\n")
    template.save!
    assert_equal "a\nb\nc\n", template.template
  end

  class AMediumProvider < MediumProviders::Provider
    def self.friendly_name
      'a_provider'
    end

    def medium_uri(path = "", &block)
      '/a_medium'
    end

    def valid?
      entity.respond_to?(:medium) && entity.medium.nil?
    end

    def validate
      []
    end

    def unique_id
      "123"
    end
  end

  describe "Association cascading" do
    setup do
      @arch = FactoryBot.create(:architecture)
      medium = FactoryBot.create(:medium, :name => "combo_medium", :path => "http://www.example.com/m")
      @os1 = FactoryBot.create(:rhel7_5, :media => [medium], :architectures => [@arch])
      @hg1 = FactoryBot.create(:hostgroup, :name => "hg1", :operatingsystem => @os1, :architecture => @arch, :medium => @os1.media.first)
      @hg2 = FactoryBot.create(:hostgroup, :name => "hg2", :operatingsystem => @os1, :architecture => @arch, :medium => @os1.media.first)
      @tk = TemplateKind.find_by_name('provision')

      # HG only
      # Most specific template association that has left after puppet env extraction
      @ct1 = FactoryBot.create(:provisioning_template, :name => "ct1", :template_kind => @tk, :operatingsystems => [@os1])
      @ct1.template_combinations.create(:hostgroup => @hg1)

      # Default template for the OS
      @ctd = FactoryBot.create(:provisioning_template, :name => "ctd", :template_kind => @tk, :operatingsystems => [@os1])
      @ctd.os_default_templates.create(:operatingsystem => @os1, :template_kind_id => @ctd.template_kind_id)

      Foreman::Plugin.medium_providers_registry.register(AMediumProvider)
    end

    teardown do
      Foreman::Plugin.medium_providers_registry.unregister(AMediumProvider)
    end

    test "medium providers validate hostgroups" do
      p1 = Foreman::Plugin.medium_providers_registry.find_provider(@hg1)
      refute_nil p1
      assert_empty p1.validate
    end

    test "find_template finds a matching template with hg and env" do
      assert_equal @ct1.name,
        ProvisioningTemplate.find_template(kind: @tk.name, operatingsystem_id: @os1.id, hostgroup_id: @hg1.id).name
    end

    test "find_template finds the default template when hg do not match" do
      assert_equal @ctd.name,
        ProvisioningTemplate.find_template(kind: @tk.name, operatingsystem_id: @os1.id, hostgroup_id: @hg2.id).name
    end

    test "pxe_default_combos should return valid combinations" do
      ProvisioningTemplate.pxe_default_combos
    end

    TemplateKind::PXE.each do |kind|
      test "should call pxe_default_combos and render the result for #{kind}" do
        return if kind == "iPXE"
        ProxyAPI::TFTP.any_instance.stubs(:create_default).returns(true)
        ProxyAPI::TFTP.any_instance.stubs(:fetch_boot_file).returns(true)
        global_template_name = ProvisioningTemplate.global_template_name_for(kind)
        default_template = ProvisioningTemplate.find_global_default_template(global_template_name, kind)
        expected = {}
        expected["PXELinux"] = [/combo_medium-[A-Za-z0-9_=]+-(vmlinuz|initrd.img)/, /LABEL hg1 - ct1/]
        expected["PXEGrub"] = [/combo_medium-[A-Za-z0-9_=]+-(vmlinuz|initrd.img)/, /title hg1 - ct1/]
        expected["PXEGrub2"] = [/combo_medium-[A-Za-z0-9_=]+-(vmlinuz|initrd.img)/, /hg1 - ct1/]
        expected[kind].each do |match|
          assert_match match, default_template.render(variables: { profiles: ProvisioningTemplate.pxe_default_combos })
        end
      end
    end

    test "should call build_pxe_default with allowed_helpers containing the default helpers" do
      ProxyAPI::TFTP.any_instance.stubs(:create_default).returns(true)
      ProxyAPI::TFTP.any_instance.stubs(:fetch_boot_file).returns(true)
      ProvisioningTemplate.any_instance.expects(:render).times(3).returns(true)
      ProvisioningTemplate.build_pxe_default
    end

    test "#metadata should include OSes and kind" do
      template = FactoryBot.build_stubbed(:provisioning_template, operatingsystems: [
                                            FactoryBot.create(:operatingsystem, name: 'CentOS'),
                                            FactoryBot.create(:operatingsystem, name: 'CentOS'),
                                            FactoryBot.create(:operatingsystem, name: 'Fedora'),
                                          ])

      lines = template.metadata.split("\n")
      assert_includes lines, '- CentOS'
      assert_includes lines, '- Fedora'
      assert_equal 1, lines.count { |l| l == '- CentOS' }
      assert_includes lines, "kind: #{template.template_kind.name}"
      assert_includes lines, "name: #{template.name}"
    end
  end

  context 'importing' do
    describe '#import_custom_data' do
      setup do
        @template = ProvisioningTemplate.new
        @template.stubs(:import_oses)
      end

      test 'it sets kind to nil if snippet is being imported' do
        @template.instance_variable_set '@importing_metadata', { 'kind' => 'some' }
        @template.snippet = true
        @template.send :import_custom_data, { :associate => 'always' }
        assert_nil @template.template_kind
      end

      test 'it skips kind selection if it is missing in metadata' do
        @template.instance_variable_set '@importing_metadata', { }
        @template.send :import_custom_data, { :associate => 'always' }
        assert_nil @template.template_kind
      end

      test 'it sets the kind based on metadata' do
        kind = FactoryBot.create(:template_kind)
        @template.instance_variable_set '@importing_metadata', { 'kind' => kind.name }
        @template.send :import_custom_data, { :associate => 'always' }
        assert_equal kind, @template.template_kind
      end

      test 'it errors out if invalid/unknown kind was specified' do
        @template.instance_variable_set '@importing_metadata', { 'kind' => 'not existing kind name' }
        @template.send :import_custom_data, { :associate => 'always' }
        assert_nil @template.template_kind
        assert_includes @template.errors.keys, :template_kind_id
      end
    end

    describe 'import_without_save' do
      test 'it correctly imports provisioning template with :associate => "never"' do
        text = File.read(Foreman::Application.root.join('test', 'static_fixtures', 'templates', 'provision', 'one.erb'))
        template = ProvisioningTemplate.import_without_save('not_associated_templates', text, { :associate => 'never' })
        assert template.template_kind
        assert_empty template.operatingsystems
        assert template.valid?
      end
    end
  end

  test "should not allow to assign OS to the registration kind" do
    template_kind = template_kinds(:registration)
    os = operatingsystems(:redhat)
    template = FactoryBot.build(:provisioning_template, template: "a", template_kind: template_kind, operatingsystems: [os])

    refute template.valid?
    assert_includes template.errors.keys, :operatingsystems
  end
end
