require 'test_helper'

class TemplateKindTest < ActiveSupport::TestCase
  test '#to_s returns English string for default template kinds' do
    assert_equal 'iPXE template', TemplateKind.find_by_name('iPXE').to_s
  end

  test '#to_s returns English string from plugin registration' do
    kind = FactoryBot.build_stubbed(:template_kind)
    mock_plugin = mock('plugin')
    mock_plugin.expects(:get_template_labels).at_least_once.returns({kind.name => 'Plugin kind'})
    Foreman::Plugin.expects(:all).at_least_once.returns([mock_plugin])
    assert_equal 'Plugin kind', kind.to_s
  end

  test '#to_s returns name for unknown kinds' do
    kind = FactoryBot.build_stubbed(:template_kind)
    assert_equal kind.name, kind.to_s
  end

  test '#default_template_descriptions returns description of every template kind' do
    tmpl = TemplateKind.default_template_descriptions
    tmpl.keys.each do |type|
      assert_not_empty tmpl[type]
    end
  end
end
