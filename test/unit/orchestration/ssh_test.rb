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

  describe '#setSSHWaitForResponse' do
    setup do
      @host = FactoryBot.build(:host, :managed)
      @host.stubs(:provision_host).returns('10.0.0.1')
      @host.stubs(:uuid).returns('test-uuid')
      @template_file = Tempfile.new('template')
      @host.template_file = @template_file
      @image = stub('image', :password => 'img-pass', :username => 'image-user')
      @host.stubs(:image).returns(@image)
    end

    teardown do
      @template_file&.unlink
    end

    test 'prefers vm username over image username' do
      vm = stub('vm', :password => 'vm-pass', :username => 'vm-user')
      @host.stubs(:vm).returns(vm)
      compute_resource = stub('compute_resource')
      compute_resource.stubs(:key_pair).returns(nil)
      @host.stubs(:compute_resource).returns(compute_resource)
      ssh_client = mock('ssh client')
      ssh_client.expects(:ping).returns(true)
      Foreman::Provision::Ssh.expects(:new).with('10.0.0.1', 'vm-user', has_entries(:password => 'vm-pass', :template => @template_file.path, :uuid => 'test-uuid')).returns(ssh_client)
      @host.send(:setSSHWaitForResponse)
    end

    test 'falls back to image username when vm username is nil' do
      vm = stub('vm', :password => 'vm-pass', :username => nil)
      @host.stubs(:vm).returns(vm)
      compute_resource = stub('compute_resource')
      compute_resource.stubs(:key_pair).returns(nil)
      @host.stubs(:compute_resource).returns(compute_resource)
      ssh_client = mock('ssh client')
      ssh_client.expects(:ping).returns(true)
      Foreman::Provision::Ssh.expects(:new).with('10.0.0.1', 'image-user', has_entries(:password => 'vm-pass', :template => @template_file.path, :uuid => 'test-uuid')).returns(ssh_client)
      @host.send(:setSSHWaitForResponse)
    end

    test 'falls back to image username when vm does not respond to username' do
      vm = stub('vm', :password => 'vm-pass')
      @host.stubs(:vm).returns(vm)
      compute_resource = stub('compute_resource')
      compute_resource.stubs(:key_pair).returns(nil)
      @host.stubs(:compute_resource).returns(compute_resource)
      ssh_client = mock('ssh client')
      ssh_client.expects(:ping).returns(true)
      Foreman::Provision::Ssh.expects(:new).with('10.0.0.1', 'image-user', has_entries(:password => 'vm-pass', :template => @template_file.path, :uuid => 'test-uuid')).returns(ssh_client)
      @host.send(:setSSHWaitForResponse)
    end

    test 'uses key pair authentication when available' do
      key_pair = stub('key_pair', :secret => 'ssh-secret-key')
      compute_resource = stub('compute_resource', :key_pair => key_pair)
      @host.stubs(:compute_resource).returns(compute_resource)
      vm = stub('vm', :username => 'vm-user')
      @host.stubs(:vm).returns(vm)
      ssh_client = mock('ssh client')
      ssh_client.expects(:ping).returns(true)
      Foreman::Provision::Ssh.expects(:new).with('10.0.0.1', 'vm-user', has_entries(:key_data => 'ssh-secret-key', :template => @template_file.path, :uuid => 'test-uuid')).returns(ssh_client)
      @host.send(:setSSHWaitForResponse)
    end

    test 'uses image password when vm has no password' do
      vm = stub('vm', :username => 'vm-user')
      @host.stubs(:vm).returns(vm)
      compute_resource = stub('compute_resource')
      compute_resource.stubs(:key_pair).returns(nil)
      @host.stubs(:compute_resource).returns(compute_resource)
      ssh_client = mock('ssh client')
      ssh_client.expects(:ping).returns(true)
      Foreman::Provision::Ssh.expects(:new).with('10.0.0.1', 'vm-user', has_entries(:password => 'img-pass', :template => @template_file.path, :uuid => 'test-uuid')).returns(ssh_client)
      @host.send(:setSSHWaitForResponse)
    end

    test 'fails when no authentication method is available' do
      vm = stub('vm', :username => 'vm-user')
      @host.stubs(:vm).returns(vm)
      compute_resource = stub('compute_resource')
      compute_resource.stubs(:key_pair).returns(nil)
      @host.stubs(:compute_resource).returns(compute_resource)
      @image.stubs(:password).returns(nil)
      @host.expects(:failure).with(regexp_matches(/Unable to find proper authentication method/), is_a(Foreman::Exception))
      @host.send(:setSSHWaitForResponse)
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
