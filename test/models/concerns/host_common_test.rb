require 'test_helper'

class HostCommonTest < ActiveSupport::TestCase
  test 'does not copy encoded Base64 root passwords to grub passwords' do
    %w[Base64 Base64-Windows].each do |password_hash|
      host = FactoryBot.build(:host, :managed)
      host.operatingsystem.password_hash = password_hash
      host[:root_pass] = 'encoded root password'
      host[:grub_pass] = nil
      host.stubs(:password_base64_encrypted?).returns(true)

      host.crypt_passwords

      assert_equal 'encoded root password', host.root_pass
      assert_nil host.grub_pass
    end
  end

  test 'derives root and grub passwords from a cleartext Linux password' do
    host = FactoryBot.build(:host, :managed)
    host.operatingsystem.password_hash = 'SHA512'
    host[:root_pass] = 'cleartext root password'
    host[:grub_pass] = nil

    host.crypt_passwords

    assert_match(/^\$6\$/, host.root_pass)
    assert_match(/^\$6\$/, host.grub_pass)
  end

  test 'preserves an explicit grub password with an encoded root password' do
    host = FactoryBot.build(:host, :managed)
    host.operatingsystem.password_hash = 'Base64-Windows'
    host[:root_pass] = 'encoded root password'
    host[:grub_pass] = '$6$explicit$grub-password'
    host.stubs(:password_base64_encrypted?).returns(true)

    host.crypt_passwords

    assert_equal '$6$explicit$grub-password', host.grub_pass
  end
end
