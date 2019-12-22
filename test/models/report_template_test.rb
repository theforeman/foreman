require 'test_helper'

class ReportTemplateTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  test "#suggested_report_name" do
    report = FactoryBot.build :report_template, name: 'my report'
    assert_equal "my report-#{Date.today}", report.suggested_report_name
  end

  test "#supports_format_selection?" do
    report_without_macro = FactoryBot.build :report_template, template: '<% 1 + 1 %>'
    refute report_without_macro.supports_format_selection?

    report_with_macro = FactoryBot.build :report_template, template: <<~EOT
      <% # some report using report macros %>
      <% report_row a: 1 %>
      <% report_row a: 2 %>
      <% report_render %>
    EOT
    assert report_with_macro.supports_format_selection?
  end
end
