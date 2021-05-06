require 'test_helper'

class Foreman::Renderer::Source::SnapshotTest < ActiveSupport::TestCase
  let(:subject) { Foreman::Renderer::Source::Snapshot }
  let(:templates_directory) { File.join(__dir__, '../../../../static_fixtures/templates') }
  let(:file) { File.join(templates_directory, 'provision', 'one.erb') }
  let(:template) { subject.load_file(file) }
  let(:source) { subject.new(template) }

  setup do
    Foreman::Renderer::Source::Snapshot.any_instance.stubs(:templates_directory).returns(templates_directory)
  end

  describe '#name' do
    test 'should return the template name from the metadata' do
      assert_equal 'One', source.name
    end
  end

  describe '#find_snippet' do
    test 'finds a snippet' do
      assert_equal 'two', source.find_snippet('two').name
    end
  end

  describe '#snapshot_path' do
    test 'generates correct snapshot path' do
      assert_equal Rails.root.join('test/unit/foreman/renderer/snapshots/ProvisioningTemplate/provision/One.host4dhcp.snap.txt').to_s, subject.snapshot_path(template)
    end
  end

  describe 'rendering' do
    test 'renders a template with nested snippets' do
      host = FactoryBot.create(:host, :managed)
      scope = Foreman::Renderer.get_scope(host: host, source: source)
      assert_equal '1234', Foreman::Renderer.render(source, scope).gsub(/[[:space:]]/, '')
    end
  end
end
