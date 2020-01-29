class SshKeysFingerprintsSha1 < ActiveRecord::Migration[5.2]
  def up
    SshKey.all.each { |ssh_key| ssh_key.update_column('fingerprint', SSHKey.sha256_fingerprint(ssh_key.key)) }
  end

  def down
    SshKey.all.each { |ssh_key| ssh_key.update_column('fingerprint', SSHKey.fingerprint(ssh_key.key)) }
  end
end
