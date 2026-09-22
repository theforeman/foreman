require 'test_helper'

class ReportTemplateTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  test "#suggested_report_name" do
    report = FactoryBot.build :report_template, name: 'my report'
    assert_equal "my report-#{Date.today}", report.suggested_report_name
  end

  test "Host - Registered Content Hosts preloads has-many associations (fixes #39779)" do
    template = File.read(Rails.root.join('app/views/unattended/report_templates/host_-_registered_content_hosts.erb'))
    load_line = template.lines.find { |line| line.include?('load_hosts(') }
    assert load_line, 'expected the template to call load_hosts'

    # A search referencing a has-many association (e.g. Katello's
    # installed_package_name) forces Rails to upgrade includes: into an
    # eager_load JOIN; has-many associations in includes: then fan out a
    # Cartesian product per host and OOM the worker. belongs_to stays in
    # includes:, has-many must use preload:.
    refute_includes load_line, ':applicable_errata',
      'applicable_errata is re-queried per host, do not include it'
    refute_match(/includes:\s*\[[^\]]*:interfaces/, load_line,
      'has-many :interfaces must not be in includes:')
    assert_match(/preload:\s*\[[^\]]*:interfaces/, load_line,
      'has-many :interfaces must be in preload:')
    assert_match(/includes:\s*\[[^\]]*:operatingsystem/, load_line,
      'belongs_to :operatingsystem stays in includes:')
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
