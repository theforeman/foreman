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

  test "default 'Host - Registered Content Hosts' template does not eager-load has_many associations" do
    template_path = Rails.root.join('app/views/unattended/report_templates/host_-_registered_content_hosts.erb')
    content = File.read(template_path)

    load_hosts_call = content[/load_hosts\(.*?\)\.each_record/m]
    refute_nil load_hosts_call, "expected to find a load_hosts(...).each_record call in the template"

    # includes: on a has_many can silently become an eager_load JOIN (SAT-50727)
    includes_clause = load_hosts_call[/includes:\s*\[([^\]]*)\]/, 1] || ''

    refute_includes includes_clause, ':interfaces'
    refute_includes includes_clause, ':applicable_errata'
    refute_includes includes_clause, ':operatingsystem'
  end
end
