require 'test_helper'

class Foreman::Provision::SshKeyTest < ActiveSupport::TestCase
  KEYS = {
    'rsa2048'  => { fingerprint: 'YM91jAmHbxhgh/d1NtHzBtGqqR1ARwVb0KDF0pGZAVc=', length: 2048 },
    'rsa4096'  => { fingerprint: '8rD/tQMje6HUk1dZELelNM5SMpiGO+1BrEgrfSZdvg0=', length: 4096 },
    'ecdsa256' => { fingerprint: '4dEJKo6jNj7vVT6Y90D5UQf6QIJ6/U65GAlP+C86zhw=', length: 256 },
    'ecdsa384' => { fingerprint: 'wFWPwwLl/pMIsCcJATtzNuly0V4rIQcyS6Bp8Icrb5Y=', length: 384 },
    'ecdsa521' => { fingerprint: '3x7Jb/6rsjGjALMvKGznxc9cw+63YCHhXeOnJ9qs7DM=', length: 521 },
    'ed25519'  => { fingerprint: 'dkKrxf6K2+QZlM3c0JMc7pGvr33OkamPFAG+6n93v5k=', length: 256 },
  }.freeze

  def public_key(name)
    File.read(Rails.root.join("test/static_fixtures/ssh_keys/#{name}.pub")).strip
  end

  KEYS.each do |name, expected|
    context "with a #{name} public key" do
      let(:key) { public_key(name) }
      let(:service) { Foreman::Provision::SshKey.new(key) }

      test 'is valid' do
        assert service.valid?
      end

      test 'calculates the fingerprint' do
        assert_equal expected[:fingerprint], service.fingerprint
      end

      test 'calculates the length' do
        assert_equal expected[:length], service.length
      end
    end
  end

  context 'with an unparseable key' do
    let(:service) { Foreman::Provision::SshKey.new('this-is-not-a-key') }

    test 'is not valid' do
      refute service.valid?
    end

    test 'raises Error when calculating the fingerprint' do
      assert_raises(Foreman::Provision::SshKey::Error) { service.fingerprint }
    end

    test 'raises Error when calculating the length' do
      assert_raises(Foreman::Provision::SshKey::Error) { service.length }
    end
  end

  context 'when the underlying implementation raises' do
    let(:key) { public_key('rsa2048') }
    let(:service) { Foreman::Provision::SshKey.new(key) }

    setup do
      Open3.stubs(:capture3).returns(['', 'ssh-keygen boom', stub(:success? => false)])
    end

    test 'raises Error when calculating the fingerprint' do
      assert_raises(Foreman::Provision::SshKey::Error) { service.fingerprint }
    end

    test 'raises Error when calculating the length' do
      assert_raises(Foreman::Provision::SshKey::Error) { service.length }
    end

    test 'reports the key as invalid' do
      refute service.valid?
    end
  end

  context '.generate' do
    test 'generates a valid public key' do
      key = Foreman::Provision::SshKey.generate
      assert Foreman::Provision::SshKey.new(key).valid?
    end

    %w[rsa ecdsa ed25519].each do |type|
      test "generates a valid #{type} key" do
        key = Foreman::Provision::SshKey.generate(:type => type)
        assert Foreman::Provision::SshKey.new(key).valid?
      end
    end

    test 'generates a unique key on every call' do
      refute_equal Foreman::Provision::SshKey.generate, Foreman::Provision::SshKey.generate
    end

    test 'appends the given comment' do
      key = Foreman::Provision::SshKey.generate(:comment => 'foreman@example.com')
      assert_equal 'foreman@example.com', key.split(' ').last
    end

    test 'raises Error on an unknown key type' do
      assert_raises(Foreman::Provision::SshKey::Error) do
        Foreman::Provision::SshKey.generate(:type => 'nonsense')
      end
    end
  end
end
