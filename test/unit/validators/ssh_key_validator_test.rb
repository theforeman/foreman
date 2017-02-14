require 'test_helper'

class SshKeyValidatorTest < ActiveSupport::TestCase
  class Validatable
    include ActiveModel::Validations
    validates :key, :ssh_key => true
    attr_accessor :key
  end

  let(:validatable) { Validatable.new }

  test 'should pass when ssh key is valid' do
    validatable.key = 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIhRoL6PfBRs9YwW3r2/pYeLrxRzEZSUO3Go8JivxMsguEKjJ3byHDPvPpMHhKKSZD/HJY/A+2Ndqp0ElB+t2qs= foreman@example.com'
    assert validatable.valid?
  end

  test 'should fail when ssh key invalid' do
    validatable.key = 'ssh-rsa abcdefghijklmnop foreman@example.com'
    refute validatable.valid?
  end

  test 'should allow blank' do
    assert validatable.valid?
  end
end
