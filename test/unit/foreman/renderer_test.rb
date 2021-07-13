#
# This test tries to render all templates mentioned in snapshots.yaml
# and compares the result with copies in test/unit/foreman/renderer/snapshots.
# After review of changes, snapshots can be easily regenerated with:
#
#   bundle exec rake snapshots:generate RAILS_ENV=test
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

  private

  def assert_template(template)
    Foreman::Renderer::Source::Snapshot.hosts(template).each do |host|
      snapshot_path = Foreman::Renderer::Source::Snapshot.snapshot_path(template, host)
      rendered = Foreman::TemplateSnapshotService.render_template(template, host)
      unless rendered == File.read(snapshot_path)
        puts "Diff for #{snapshot_path}:"
        puts diff(File.read(snapshot_path), rendered)

        assert false, "Rendered template #{template.name} did not match the snapshot."
      end
    end
  end
end
