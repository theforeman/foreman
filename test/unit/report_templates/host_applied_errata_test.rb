require 'test_helper'

class HostAppliedErrataTemplateTest < ActiveSupport::TestCase
  def template_path
    Rails.root.join('app/views/unattended/report_templates/host_-_applied_errata.erb')
  end

  def inputs_by_name
    metadata = Template.parse_metadata(File.read(template_path))
    metadata['template_inputs'].index_by { |input| input['name'] }
  end

  test 'closed option inputs are required and have defaults' do
    expected = {
      'Filter Errata Type' => 'all',
      'Include Last Reboot' => 'no',
      'Status' => 'all',
    }

    expected.each do |name, default|
      input = inputs_by_name[name]
      assert input, "expected template input #{name}"
      assert input['required'], "#{name} should be required so the generate form shows an asterisk"
      assert_equal default, input['default'], "#{name} should default to #{default}"
      options = input['options'].to_s.split(/\r?\n/).map(&:strip)
      assert_includes options, default, "#{name} default must be one of the listed options"
    end
  end

  test 'optional search and date inputs remain optional' do
    ['Hosts filter', 'Since', 'Up to'].each do |name|
      input = inputs_by_name[name]
      assert input, "expected template input #{name}"
      refute input['required'], "#{name} should remain optional"
    end
  end
end
