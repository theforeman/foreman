require 'test_helper'

class SshOrchestrationTest < ActiveSupport::TestCase
  setup :disable_orchestration

  describe '#setSSHProvisionScript' do
    test 'set template file for host' do
      host = FactoryBot.build(:host, :managed)
      template = FactoryBot.create(:provisioning_template, template: "<%= @host.name %>")
      host.expects(:provisioning_template).returns(template)
      host.send(:setSSHProvisionScript)
      assert host.template_file.is_a?(Tempfile)
    end
  end

  test 'failed SSH deployment deletes host if enabled' do
    Setting[:clean_up_failed_deployment] = true
    ssh = mock('ssh client')
    ssh.expects(:deploy!).returns(false)
    host = FactoryBot.build(:host, :managed)
    host.expects(:client).returns(ssh)
    host.send(:setSSHProvision)
    refute Host::Managed.find_by_id(host.id)
  end

  test 'failed SSH deployment retains host if disabled' do
    Setting[:clean_up_failed_deployment] = false
    ssh = mock('ssh client')
    ssh.expects(:deploy!).returns(false)
    host = FactoryBot.create(:host, :managed)
    host.expects(:client).returns(ssh)
    host.send(:setSSHProvision)
    assert Host::Managed.find_by_id(host.id)
  end
end
