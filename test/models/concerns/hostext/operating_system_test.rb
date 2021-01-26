require 'test_helper'

module Hostext
  class OperatingSystemTest < ActiveSupport::TestCase
    context 'associated config templates' do
      setup do
        @host = Host.create(:name => "host.mydomain.net", :mac => "aabbccddeaff",
                            :ip => "2.3.04.03",           :medium => media(:one),
                            :subnet => subnets(:one), :hostgroup => Hostgroup.find_by_name("Common"),
                            :architecture => Architecture.find_by(name: 'x86_64'), :disk => "aaa")
      end

      test "retrieves iPXE template if associated to the correct env and host group" do
        assert_equal ProvisioningTemplate.find_by_name("MyString"), @host.provisioning_template({:kind => "iPXE"})
      end

      test "retrieves provision template if associated to the correct host group only" do
        assert_equal ProvisioningTemplate.find_by_name("MyString2"), @host.provisioning_template({:kind => "provision"})
      end

      test "retrieves script template if associated to the correct OS only" do
        assert_equal ProvisioningTemplate.find_by_name("MyScript"), @host.provisioning_template({:kind => "script"})
      end

      test "retrieves finish template if associated to the correct environment only" do
        assert_equal ProvisioningTemplate.find_by_name("MyFinish"), @host.provisioning_template({:kind => "finish"})
      end

      test "available_template_kinds finds templates for a PXE host" do
        os_dt = FactoryBot.create(:os_default_template,
          :template_kind => TemplateKind.friendly.find('finish'))
        host  = FactoryBot.create(:host, :operatingsystem => os_dt.operatingsystem)

        assert_equal [os_dt.provisioning_template, templates(:host_init_config)], host.available_template_kinds('build')
      end

      test "available_template_kinds finds templates for an image host" do
        Foreman::Model::EC2.any_instance.stubs(:image_exists?).returns(true)
        os_dt = FactoryBot.create(:os_default_template,
          :template_kind => TemplateKind.friendly.find('finish'))
        host  = FactoryBot.create(:host, :on_compute_resource,
          :operatingsystem => os_dt.operatingsystem)
        FactoryBot.create(:image, :uuid => 'abcde',
                           :compute_resource => host.compute_resource)
        host.compute_attributes = {:image_id => 'abcde'}

        assert_equal [os_dt.provisioning_template], host.available_template_kinds('image')
      end

      test "#render_template" do
        provision_template = @host.provisioning_template({:kind => "provision"})
        rendered_template = @host.render_template(template: provision_template)
        assert(rendered_template.include?("http://foreman.some.host.fqdn/unattended/finish"), "rendred template should parse foreman_url")
      end
    end

    test '#jumpstart? should return true for Solaris and SPARC hosts' do
      host = FactoryBot.create(:host,
        :operatingsystem => FactoryBot.create(:solaris),
        :architecture => FactoryBot.create(:architecture, :name => 'SPARC-T2'))
      assert host.jumpstart?
    end
  end
end
