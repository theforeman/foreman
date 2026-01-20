require 'test_helper'
require 'mkmf'
require 'English'

class PreseedSyntaxTest < ActiveSupport::TestCase
  files = Dir.glob('test/unit/foreman/renderer/snapshots/ProvisioningTemplate/provision/Preseed*')

  files.each do |file|
    test file do
      debconf_set_selections(file)
    end
  end

  private

  def debconf_set_selections(file)
    skip unless find_executable 'debconf-set-selections'
    output = `debconf-set-selections --checkonly '#{file}' 2>&1`
    status = $CHILD_STATUS
    assert_empty output.strip
    assert status.success?
  end
end
