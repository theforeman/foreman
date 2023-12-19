require "test_helper"
require 'mkmf'
require "English"

class GrubSyntaxTest < ActiveSupport::TestCase
  Dir.glob('test/unit/foreman/renderer/snapshots/ProvisioningTemplate/PXEGrub2/*').each do |file|
    test file do
      grub_check(file)
    end
  end

  private

  def grub_check(file)
    grub_script_check = find_executable 'grub2-script-check'
    grub_script_check ||= find_executable 'grub-script-check'
    skip unless grub_script_check
    output = `#{grub_script_check} "#{file}" 2>&1`
    status = $CHILD_STATUS
    assert_empty output
    assert status.success?
  end
end
