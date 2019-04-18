require 'test_helper'

class Foreman::RenderTemplatesFromFolderTest < ActiveSupport::TestCase
  let(:source_directory) { File.expand_path(File.join(__dir__, '../../static_fixtures/templates')) }
  let(:instance) { Foreman::RenderTemplatesFromFolder.instance(source_directory: source_directory) }

  teardown do
    Foreman::RenderTemplatesFromFolder.clear_instances
  end

  it 'renders templates from static fixtures' do
    instance.render_all
    assert_empty instance.errors
  end
end
