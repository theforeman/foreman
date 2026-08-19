require 'digest/sha2'
require 'digest/md5'
require 'base64'

class SshKeysFingerprintsSha1 < ActiveRecord::Migration[5.2]
  def up
    update_fingerprints { |blob| Base64.strict_encode64(Digest::SHA256.digest(blob)) }
  end

  def down
    update_fingerprints { |blob| Digest::MD5.hexdigest(blob).scan(/../).join(':') }
  end

  private

  def update_fingerprints
    SshKey.reset_column_information
    SshKey.all.each do |ssh_key|
      blob = Base64.decode64(ssh_key.key.to_s.split(' ')[1].to_s)
      ssh_key.update_column('fingerprint', yield(blob))
    end
  end
end
