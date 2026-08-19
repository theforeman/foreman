# Wraps the SSH public key operations (fingerprinting, key length and
# validation) behind a single interface so the underlying implementation can be
# swapped without touching the callers (model and validator).
class Foreman::Provision::SshKey
  # Raised when the key cannot be processed (e.g. malformed public key).
  class Error < StandardError; end

  attr_reader :key

  def initialize(key)
    @key = key
  end

  # Returns the SHA256 fingerprint of the public key.
  def fingerprint
    SSHKey.sha256_fingerprint(key)
  rescue SSHKey::PublicKeyError => e
    raise Error, e.message
  end

  # Returns the length of the public key in bits.
  def length
    SSHKey.ssh_public_key_bits(key)
  rescue SSHKey::PublicKeyError => e
    raise Error, e.message
  end

  # Returns true when the given public key is valid.
  def valid?
    SSHKey.valid_ssh_public_key?(key)
  rescue SSHKey::PublicKeyError => e
    raise Error, e.message
  end
end
