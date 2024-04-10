require "test_helper"
require "English"

class KickstartSyntaxTest < ActiveSupport::TestCase
  ksfiles = Dir.glob('test/unit/foreman/renderer/snapshots/ProvisioningTemplate/provision/*Kickstart*')

  ksfiles_v7 = ksfiles.select { |ks| ks.include?('host') }
  ksfiles_v8 = ksfiles.select { |ks| ks.include?('rocky8') || ks.include?('rhel8') }
  ksfiles_v9 = ksfiles.select { |ks| ks.include?('rocky9') || ks.include?('rhel9') }

  versions = { 'RHEL7' => ksfiles_v7, 'RHEL8' => ksfiles_v8, 'RHEL9' => ksfiles_v9 }

  versions.each do |version, files|
    files.each do |file|
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
    assert_empty output.strip.sub(/Checking kickstart file [^ ]+/, '')
    assert status.success?
  end
end
