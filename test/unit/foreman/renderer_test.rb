#
# This test tries to render all templates mentioned in snapshots.yaml
# and compares the result with copies in test/unit/foreman/renderer/snapshots.
# After review of changes, snapshots can be easily regenerated with:
#
#   bundle exec rake snapshots:generate RAILS_ENV=test
#

require 'test_helper'

class RendererTest < ActiveSupport::TestCase
  context 'safe mode' do
    setup do
      Setting[:safemode_render] = true
    end

    Foreman::TemplateSnapshotService.templates.each do |template, oses|
      oses.each do |os_name, os_type, os_major, os_minor|
        test "rendered #{template.name} for #{os_name} #{os_major}.#{os_minor} template should match snapshots" do
          assert_template(template, os_name, os_type, os_major, os_minor)
        end
      end
    end
  end

  context 'unsafe mode' do
    setup do
      Setting[:safemode_render] = false
    end

    Foreman::TemplateSnapshotService.templates.each do |template, oses|
      oses.each do |os_name, os_type, os_major, os_minor|
        test "rendered #{template.name} for #{os_name} #{os_major}.#{os_minor} template should match snapshots" do
          assert_template(template, os_name, os_type, os_major, os_minor)
        end
      end
    end
  end

  private

  def assert_template(template, os_name, os_type, os_major, os_minor)
    rendered = Foreman::TemplateSnapshotService.render_template(template, os_name, os_type, os_major, os_minor)
    variants = Foreman::Renderer::Source::Snapshot.snapshot_variants(template)
    match = variants.any? { |variant| rendered == File.read(variant) }
    puts(rendered) unless match

    assert match, "Rendered template #{template.name} did not match any snapshot. Tried against #{variants.join(', ')}"
  end
end
