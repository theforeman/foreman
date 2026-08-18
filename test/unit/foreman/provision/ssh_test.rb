require 'test_helper'

class SshProvisionServiceTest < ActiveSupport::TestCase
  def setup
    @template = Tempfile.new('provision-test')
    @template.write("#!/bin/sh\necho hello\n")
    @template.close
  end

  def teardown
    @template.unlink
  end

  def success_status
    stub(success?: true)
  end

  def failure_status
    stub(success?: false)
  end

  def stub_capture3(stdout: "", stderr: "", status: success_status)
    Open3.stubs(:capture3).returns([stdout, stderr, status])
  end

  def new_ssh(address: "192.168.1.1", username: "root", options: {})
    defaults = { template: @template.path, uuid: "test-uuid", key_data: "fake-private-key" }
    Foreman::Provision::Ssh.new(address, username, defaults.merge(options))
  end

  test "raises when no credentials provided" do
    assert_raises(Foreman::Exception) do
      Foreman::Provision::Ssh.new("192.168.1.1", "root", template: @template.path, uuid: "x")
    end
  end

  test "raises when template is missing" do
    assert_raises(Foreman::Exception) do
      Foreman::Provision::Ssh.new("192.168.1.1", "root", key_data: "key")
    end
  end

  describe '#deploy!' do
    test "returns true on success" do
      stub_capture3
      ssh = new_ssh
      assert ssh.deploy!
    end

    test "returns false on failure" do
      stub_capture3(status: failure_status)
      ssh = new_ssh
      refute ssh.deploy!
    end

    test "passes template content via stdin to sh" do
      ssh = new_ssh
      Open3.expects(:capture3).with do |*args|
        opts = args.last.is_a?(Hash) ? args.last : {}
        cmd_args = args.last.is_a?(Hash) ? args[0..-2] : args
        cmd_args.include?("sh") && opts[:stdin_data] == File.binread(@template.path)
      end.returns(["", "", success_status])
      ssh.deploy!
    end

    test "uses sudo for non-root user" do
      ssh = new_ssh(username: "admin")
      Open3.expects(:capture3).with do |*args|
        cmd_args = args.last.is_a?(Hash) ? args[0..-2] : args
        cmd_args.include?("sudo sh")
      end.returns(["", "", success_status])
      ssh.deploy!
    end
  end

  describe '#ping' do
    test "returns self on successful connection" do
      stub_capture3
      ssh = new_ssh
      assert_equal ssh, ssh.ping
    end

    test "raises after timeout" do
      Setting[:ssh_timeout] = 1
      stub_capture3(status: failure_status)
      ssh = new_ssh
      ssh.stubs(:sleep)
      error = assert_raises(Foreman::Exception) { ssh.ping }
      assert_match(/Failed to connect/, error.message)
    end
  end

  describe 'key file management' do
    test "key file is removed after run_ssh" do
      ssh = new_ssh
      key_paths = []
      Open3.stubs(:capture3).with do |*args|
        cmd_args = args.last.is_a?(Hash) ? args[0..-2] : args
        identity_arg = cmd_args.find { |a| a.to_s.start_with?("-oIdentityFile=") }
        if identity_arg
          path = identity_arg.sub("-oIdentityFile=", "")
          key_paths << path
          assert File.exist?(path), "Key file should exist during SSH execution"
        end
        true
      end.returns(["", "", success_status])

      ssh.ping
      assert key_paths.any?, "Expected an identity file argument"
      key_paths.each do |path|
        refute File.exist?(path), "Key file should be removed after run_ssh"
      end
    end

    test "key file has 0600 permissions" do
      ssh = new_ssh
      Open3.stubs(:capture3).with do |*args|
        cmd_args = args.last.is_a?(Hash) ? args[0..-2] : args
        identity_arg = cmd_args.find { |a| a.to_s.start_with?("-oIdentityFile=") }
        if identity_arg
          path = identity_arg.sub("-oIdentityFile=", "")
          mode = File.stat(path).mode & 0o777
          assert_equal 0o600, mode, "Key file permissions should be 0600"
        end
        true
      end.returns(["", "", success_status])
      ssh.ping
    end

    test "no identity file when using password auth" do
      ssh = new_ssh(options: { key_data: nil, password: "secret" })
      Open3.expects(:capture3).with do |*args|
        cmd_args = args.last.is_a?(Hash) ? args[0..-2] : args
        refute cmd_args.any? { |a| a.to_s.include?("IdentityFile") }, "Should not have IdentityFile"
        true
      end.returns(["", "", success_status])
      ssh.ping
    end
  end

  describe 'command building' do
    test "uses sshpass for password auth" do
      ssh = new_ssh(options: { key_data: nil, password: "secret" })
      Open3.expects(:capture3).with do |*args|
        cmd_args = args.last.is_a?(Hash) ? args[0..-2] : args
        assert_equal({"SSHPASS" => "secret"}, cmd_args[0])
        assert_equal "sshpass", cmd_args[1]
        assert_equal "-e", cmd_args[2]
        true
      end.returns(["", "", success_status])
      ssh.ping
    end

    test "includes correct ssh options" do
      ssh = new_ssh
      Open3.expects(:capture3).with do |*args|
        cmd_args = args.last.is_a?(Hash) ? args[0..-2] : args
        assert_includes cmd_args, "-oStrictHostKeyChecking=no"
        assert_includes cmd_args, "-oUserKnownHostsFile=/dev/null"
        assert_includes cmd_args, "-oConnectTimeout=4"
        assert_includes cmd_args, "-oCompression=yes"
        assert_includes cmd_args, "-oBatchMode=yes"
        assert_includes cmd_args, "-oPreferredAuthentications=publickey"
        assert_includes cmd_args, "root@192.168.1.1"
        true
      end.returns(["", "", success_status])
      ssh.ping
    end

    test "sets both auth methods when key and password present" do
      ssh = new_ssh(options: { key_data: "key", password: "pass" })
      Open3.expects(:capture3).with do |*args|
        cmd_args = args.last.is_a?(Hash) ? args[0..-2] : args
        assert_includes cmd_args, "-oPreferredAuthentications=publickey,password"
        true
      end.returns(["", "", success_status])
      ssh.ping
    end
  end
end
