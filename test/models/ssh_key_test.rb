require 'test_helper'

class SshKeyTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_presence_of(:user_id)
  should validate_presence_of(:key)
  should validate_presence_of(:fingerprint).with_message('could not be generated')
  should validate_presence_of(:length).with_message('could not be calculated')
  should belong_to(:user)
  should_not allow_values('test', 'ssh-rsa 1234567', "abc\ndef").
    for(:key)
  should allow_value('ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIhRoL6PfBRs9YwW3r2/pYeLrxRzEZSUO3Go8JivxMsguEKjJ3byHDPvPpMHhKKSZD/HJY/A+2Ndqp0ElB+t2qs= foreman@example.com').
    for(:key)

  context '#to_export' do
    let(:user) { FactoryBot.build_stubbed(:user, :login => 'sshkeytestuser') }
    let(:key) { 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIhRoL6PfBRs9YwW3r2/pYeLrxRzEZSUO3Go8JivxMsguEKjJ3byHDPvPpMHhKKSZD/HJY/A+2Ndqp0ElB+t2qs= foreman@example.com' }
    let(:ssh_key) { FactoryBot.build_stubbed(:ssh_key, :key => key, :user => user) }

    test 'should clean up ssh key' do
      assert_equal 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIhRoL6PfBRs9YwW3r2/pYeLrxRzEZSUO3Go8JivxMsguEKjJ3byHDPvPpMHhKKSZD/HJY/A+2Ndqp0ElB+t2qs= sshkeytestuser@foreman.some.host.fqdn', ssh_key.to_export
    end
  end

  context 'Jail' do
    test 'should allow methods' do
      allowed = [:name, :user, :key, :to_export, :fingerprint, :length]

      allowed.each do |m|
        assert SshKey::Jail.allowed?(m), "Method #{m} is not available in SshKey::Jail while should be allowed."
      end
    end
  end
end
