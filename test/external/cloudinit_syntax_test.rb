require 'test_helper'
require 'mkmf'
require 'English'

class CloudInitSyntaxTest < ActiveSupport::TestCase
  files = Dir.glob('test/unit/foreman/renderer/snapshots/ProvisioningTemplate/cloud-init/*')

  files.each do |file|
    test file do
      cloudinit_schema(file)
    end
  end

  private

  def cloudinit_schema(file)
    # we do not use the `cloud-init` command directly, but it allows to identify whether cloud-init is installed
    skip unless find_executable 'cloud-init'
    output = `./script/cloud-init-validate '#{file}' 2>&1`
    status = $CHILD_STATUS
    assert_empty output.strip
    assert status.success?
  end
end
