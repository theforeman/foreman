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

  test 'Windows script escapes percent signs in the tokenless built URL' do
    Setting[:token_duration] = 0
    host = Foreman::TemplateSnapshotService.new.windows10_dhcp
    host.provision_interface.mac = '00:11:22:33:44:55'
    template = Foreman::Renderer::Source::Snapshot.load_file(
      Rails.root.join('app/views/unattended/provisioning_templates/script/windows_default_script.erb')
    )
    source = Foreman::Renderer::Source::Snapshot.new(template)
    scope = Foreman::Renderer.get_scope(host: host, source: source)

    rendered = Foreman::Renderer.render(source, scope)

    assert_includes rendered, '%WGET% http://foreman.example.com/unattended/built?mac=00%%3A11%%3A22%%3A33%%3A44%%3A55'
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
