#
# This test tries to render all templates mentioned in snapshots.yaml
# and compares the result with copies in test/unit/foreman/renderer/snapshots.
# After review of changes, snapshots can be easily regenerated with:
#
#   bundle exec rake snapshots:generate RAILS_ENV=test
#

require 'test_helper'
require_relative 'renderer/template_snapshot_service'

class RendererTest < ActiveSupport::TestCase
  context 'safe mode' do
    setup do
      Setting[:safemode_render] = true
    end

    TemplateSnapshotService.sources.each do |source|
      test "rendered #{source.name} template should match snapshots" do
        assert_template(source)
      end
    end
  end

  context 'unsafe mode' do
    setup do
      Setting[:safemode_render] = false
    end

    TemplateSnapshotService.sources.each do |source|
      test "rendered #{source.name} template should match snapshots" do
        assert_template(source)
      end
    end
  end

  private

  def assert_template(source)
    rendered = render_template(source)
    expected = File.read(source.snapshot_path)

    assert_equal(rendered, expected, "Rendered #{source.name} is different than snapshot")
  end

  def render_template(source)
    scope = Foreman::Renderer.get_scope(host: host, source: source)
    Foreman::Renderer.render(source, scope)
  end

  def host
    @host ||= TemplateSnapshotService.host
  end
end
