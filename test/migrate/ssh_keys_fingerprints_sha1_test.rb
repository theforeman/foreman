require 'test_helper'
require Rails.root.join('db/migrate/20200127103144_ssh_keys_fingerprints_sha1.rb')

class SshKeysFingerprintsSha1Test < ActiveSupport::TestCase
  let(:migration) { SshKeysFingerprintsSha1.new }

  # A key fixture with pre-computed fingerprints in both formats.
  let(:key) { File.read(Rails.root.join('test/static_fixtures/ssh_keys/ed25519.pub')).strip }
  let(:sha256_fingerprint) { 'dkKrxf6K2+QZlM3c0JMc7pGvr33OkamPFAG+6n93v5k=' }
  let(:md5_fingerprint) { '2f:96:e2:14:3e:ae:b4:78:b8:fa:1e:85:da:14:f9:69' }
  let(:ssh_key) { FactoryBot.create(:ssh_key, :key => key) }

  test 'up rewrites the fingerprint into the sha256 format' do
    ssh_key.update_column('fingerprint', 'stale-fingerprint')

    migration.up

    assert_equal sha256_fingerprint, ssh_key.reload.fingerprint
  end

  test 'down rewrites the fingerprint into the legacy md5 format' do
    assert_equal sha256_fingerprint, ssh_key.reload.fingerprint

    migration.down

    assert_equal md5_fingerprint, ssh_key.reload.fingerprint
  end
end
