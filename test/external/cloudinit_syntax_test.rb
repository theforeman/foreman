require 'test_helper'
require 'mkmf'
require 'English'

class CloudInitSyntaxTest < ActiveSupport::TestCase
  files = Dir.glob('test/unit/foreman/renderer/snapshots/ProvisioningTemplate/*/*').select do |f|
    content = File.read(f)
    # coreos and rancheros have own cloud-init implementations, which we can't validate using
    # the original cloud-init tooling
    content.match?(/^#cloud-config/) && !content.match?(/coreos:/) && !content.match?(/rancher:/)
  end

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
    assert status.success?, "cloud-init-validate result:\n#{output.strip}"
  end
end
