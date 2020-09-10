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
    rendered = Foreman::TemplateSnapshotService.render_template(template)
    variants = Foreman::Renderer::Source::Snapshot.snapshot_variants(template)
    match = variants.any? { |variant| rendered == File.read(variant) }

    assert match, "Rendered template #{template.name} did not match any snapshot. Tried against #{variants.join(', ')}"
  end
end
