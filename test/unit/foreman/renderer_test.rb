#
# This test tries to render all templates mentioned in snapshots.yaml
# and compares the result with copies in test/unit/foreman/renderer/snapshots.
# After review of changes, snapshots can be easily regenerated with:
#
#   bin/rake snapshots:generate RAILS_ENV=test
#

require 'test_helper'

class RendererTest < ActiveSupport::TestCase
  setup do
    # don't advertise any plugins to prevent different results
    ::Foreman::Plugin.stubs(:find).returns(nil)

    # dns_query macro
    Resolv::DNS.any_instance.stubs(:getaddress).returns('127.0.0.15')
  end

  context 'safe mode' do
    setup do
      Setting[:safemode_render] = true
    end

    Foreman::TemplateSnapshotService.templates.each do |template|
      test "rendered #{template.name} template should match snapshots" do
        assert_template(template)
      end
    end
  end

  context 'unsafe mode' do
    setup do
      Setting[:safemode_render] = false
    end

    Foreman::TemplateSnapshotService.templates.each do |template|
      test "rendered #{template.name} template should match snapshots" do
        assert_template(template)
      end
    end
  end

  test 'temporary template rendering preserves the template name' do
    template = FactoryBot.build_stubbed(
      :provisioning_template,
      name: 'Named finish template',
      template: '<%= template_name %>'
    )

    tempfile = Foreman::Renderer.render_template_to_tempfile(template: template, prefix: 'renderer-test')

    assert_equal template.name, File.read(tempfile.path)
  ensure
    tempfile&.close!
  end

  test 'Ubuntu autoinstall uses the universe ISO source including its scheme and path' do
    Setting[:safemode_render] = true
    template = Foreman::Renderer::Source::Snapshot.load_file(
      Rails.root.join('app/views/unattended/provisioning_templates/PXEGrub2/preseed_default_pxegrub2_autoinstall.erb'))
    host = Foreman::TemplateSnapshotService.new.ubuntu_autoinst4dhcp
    source = Foreman::Renderer::Source::Snapshot.new(template)
    iso = 'https://releases.example.test/26.04/ubuntu-26.04-live-server-amd64.iso'
    scope = Foreman::Renderer.get_scope(host: host, source: source, variables: {
      kernel: 'bootloader-universe/pxegrub2/ubuntu/26.04/x86_64/linux',
      initrd: 'bootloader-universe/pxegrub2/ubuntu/26.04/x86_64/initrd.gz',
      installation_iso: iso,
    })

    rendered = Foreman::Renderer.render(source, scope)

    assert_includes rendered, "url=#{iso} "
    assert_includes rendered, 'bootloader-universe/pxegrub2/ubuntu/26.04/x86_64/linux'
    assert_includes rendered, 'bootloader-universe/pxegrub2/ubuntu/26.04/x86_64/initrd.gz'
  end

  test 'PXEGrub2 preview and deployment render the universe paths for their MACs' do
    Setting[:safemode_render] = true
    host = FactoryBot.build_stubbed(:host, :managed, :build => false,
      :operatingsystem => operatingsystems(:redhat), :architecture => architectures(:x86_64))
    host.pxe_loader = 'Grub2 UEFI'
    template = FactoryBot.build_stubbed(:provisioning_template,
      template_kind: template_kinds(:pxegrub2),
      template: File.read(Rails.root.join('app/views/unattended/provisioning_templates/PXEGrub2/kickstart_default_pxegrub2.erb')))
    httpboot_proxy = FactoryBot.build_stubbed(:smart_proxy)
    httpboot_proxy.stubs(httpboot_http_port: 8000, httpboot_https_port: nil, hostname: 'proxy.example.test')
    subnet = FactoryBot.build(:subnet_ipv4_dhcp_for_snapshots)
    subnet.stubs(:httpboot).returns(httpboot_proxy)
    host.provision_interface.stubs(subnet: subnet, subnet6: nil)
    plan = { kernel: 'bootloader-universe/vmlinuz', initrd: 'bootloader-universe/initrd.img' }
    checker = mock('bootloader universe planner')
    Foreman::BootloaderUniverse::HostBootFiles.expects(:new).with(host).returns(checker)
    checker.expects(:plan).returns(plan)

    preview = template.render(host: host, mode: Foreman::Renderer::PREVIEW_MODE,
      source_klass: Foreman::Renderer::Source::Snapshot)
    primary_dir = "host-config/#{host.provision_interface.mac.tr(':', '-').downcase}/grub2"
    assert_includes preview, 'if [ -s vmlinuz ]; then'
    assert_includes preview, "set foreman_kernel=#{primary_dir}/vmlinuz"
    assert_includes preview, "set foreman_initrd=#{primary_dir}/initrd.img"
    assert_includes preview, 'linux $foreman_kernel'
    assert_includes preview, 'initrd $foreman_initrd'
    assert_includes preview, "/httpboot/#{primary_dir}/vmlinuz"

    other_mac = 'aa:bb:cc:dd:ee:f2'
    Setting[:safemode_render] = false
    deployed = template.render(host: host, variables: { universe_boot_files: plan, boot_mac: other_mac },
      source_klass: Foreman::Renderer::Source::Snapshot)
    assert_includes deployed, "set foreman_kernel=host-config/#{other_mac.tr(':', '-')}/grub2/vmlinuz"
    assert_includes deployed, 'linux $foreman_kernel'
  end

  test 'Ubuntu PXEGrub2 preview passes the planned ISO to autoinstall options' do
    Setting[:safemode_render] = true
    host = Foreman::TemplateSnapshotService.new.ubuntu_autoinst4dhcp
    host.pxe_loader = 'Grub2 UEFI'
    template = FactoryBot.build_stubbed(:provisioning_template,
      template_kind: template_kinds(:pxegrub2),
      template: File.read(Rails.root.join('app/views/unattended/provisioning_templates/PXEGrub2/preseed_default_pxegrub2_autoinstall.erb')))
    plan = {
      kernel: 'bootloader-universe/pxegrub2/ubuntu/26.04/x86_64/linux',
      initrd: 'bootloader-universe/pxegrub2/ubuntu/26.04/x86_64/initrd.gz',
      installation_iso: 'https://releases.example.test/ubuntu-26.04-live-server-amd64.iso',
    }
    checker = mock('bootloader universe planner')
    Foreman::BootloaderUniverse::HostBootFiles.expects(:new).with(host).returns(checker)
    checker.expects(:plan).returns(plan)

    rendered = template.render(host: host, mode: Foreman::Renderer::PREVIEW_MODE,
      source_klass: Foreman::Renderer::Source::Snapshot)

    assert_includes rendered, 'if [ -s linux ]; then'
    assert_includes rendered, 'linuxefi $foreman_kernel'
    assert_includes rendered, "url=#{plan[:installation_iso]}"
  end

  private

  def assert_template(template)
    Foreman::Renderer::Source::Snapshot.hosts(template).each do |host|
      snapshot_path = Foreman::Renderer::Source::Snapshot.snapshot_path(template, host)
      rendered = Foreman::TemplateSnapshotService.render_template(template, host)
      assert_equal File.read(snapshot_path), rendered, "Rendered template #{template.name} did not match the snapshot."
    end
  end
end
