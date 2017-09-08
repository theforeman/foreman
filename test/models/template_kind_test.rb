require 'test_helper'

class TemplateKindTest < ActiveSupport::TestCase
  test '#to_s returns English string for default template kinds' do
    assert_equal 'iPXE template', TemplateKind.find_by_name('iPXE').to_s
  end

  test '#to_s returns English string from plugin registration' do
    kind = FactoryBot.build(:template_kind)
    mock_plugin = mock('plugin')
    mock_plugin.expects(:get_template_labels).at_least_once.returns({kind.name => 'Plugin kind'})
    Foreman::Plugin.expects(:all).at_least_once.returns([mock_plugin])
    assert_equal 'Plugin kind', kind.to_s
  end

  test '#to_s returns name for unknown kinds' do
    kind = FactoryBot.build(:template_kind)
    assert_equal kind.name, kind.to_s
  end
end
