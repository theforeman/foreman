require 'test_helper'

class SshOrchestrationTest < ActiveSupport::TestCase
  setup :disable_orchestration

  test 'failed SSH deployment deletes host if enabled' do
    Setting[:clean_up_failed_deployment] = true
    ssh = mock('ssh client')
    ssh.expects(:deploy!).returns(false)
    host = FactoryGirl.create(:host, :managed)
    host.expects(:client).returns(ssh)
    host.send(:setSSHProvision)
    refute Host::Managed.find_by_id(host.id)
  end

  test 'failed SSH deployment retains host if disabled' do
    Setting[:clean_up_failed_deployment] = false
    ssh = mock('ssh client')
    ssh.expects(:deploy!).returns(false)
    host = FactoryGirl.create(:host, :managed)
    host.expects(:client).returns(ssh)
    host.send(:setSSHProvision)
    assert Host::Managed.find_by_id(host.id)
  end
end
