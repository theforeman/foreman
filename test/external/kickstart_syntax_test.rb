require "test_helper"
require "English"

class KickstartSyntaxTest < ActiveSupport::TestCase
  # Kickstart snapshots are generated only for EL7
  ["RHEL7"].each do |version|
    Dir.glob('test/unit/foreman/renderer/snapshots/ProvisioningTemplate/provision/*Kickstart*').each do |file|
      context version do
        test file do
          ksvalidator(file, version)
        end
      end
    end
  end

  private

  def ksvalidator(file, version)
    skip unless find_executable 'ksvalidator'
    output = `ksvalidator --version #{version} '#{file}' 2>&1`
    status = $CHILD_STATUS
    assert_empty output
    assert status.success?
  end
end
