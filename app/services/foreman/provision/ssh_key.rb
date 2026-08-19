require 'open3'
require 'tmpdir'

# Wraps the SSH public key operations (fingerprinting, key length and
# validation) behind a single interface. The work is delegated to the OpenSSH
# ssh-keygen command line tool so no third party gem (and its own crypto
# implementation) is needed, which keeps the behaviour aligned with OpenSSH and
# friendly to FIPS/PQC requirements.
class Foreman::Provision::SshKey
  # Raised when the key cannot be processed (e.g. malformed public key).
  class Error < StandardError; end

  # Generates a brand new SSH key pair with ssh-keygen and returns its public
  # key as an OpenSSH format string, i.e. the value that would be stored on an
  # SshKey record. The key pair is created in a temporary directory and the
  # private key is discarded; only the public key is returned.
  #
  # This is meant to be used by tests and plugins that need a valid, unique
  # public key without shipping a static fixture.
  #
  # Parameters:
  #   type:    optional key type passed to `ssh-keygen -t` (e.g. rsa, ecdsa,
  #            ed25519). When omitted, ssh-keygen picks its own default type.
  #   comment: comment appended to the public key via `ssh-keygen -C`.
  #   bits:    optional key size passed to `ssh-keygen -b`. Ignored by key
  #            types with a fixed size such as ed25519.
  #
  # Returns the public key String. Raises Error when ssh-keygen fails.
  def self.generate(type: nil, comment: '', bits: nil)
    Dir.mktmpdir('foreman-ssh-key') do |dir|
      path = File.join(dir, 'key')
      args = ['ssh-keygen', '-N', '', '-C', comment.to_s, '-f', path, '-q']
      args += ['-t', type.to_s] if type
      args += ['-b', bits.to_s] if bits
      _stdout, stderr, status = Open3.capture3(*args)
      raise Error, "unable to generate SSH key: #{stderr}" unless status.success?

      File.read("#{path}.pub").strip
    end
  end

  attr_reader :key

  def initialize(key)
    @key = key
  end

  # Returns the SHA256 fingerprint of the public key, base64 encoded (without
  # the "SHA256:" prefix ssh-keygen would print).
  def fingerprint
    info.fetch(:fingerprint)
  end

  # Returns the length of the public key in bits.
  def length
    info.fetch(:length)
  end

  # Returns true when the given public key is valid.
  def valid?
    parse
    true
  rescue Error
    false
  end

  private

  def info
    @info ||= parse
  end

  # Runs `ssh-keygen -l` against the key (fed via stdin) and parses its output,
  # which looks like: "256 SHA256:<base64> comment (ED25519)".
  def parse
    stdout, _stderr, status = Open3.capture3('ssh-keygen', '-l', '-f', '-', stdin_data: key.to_s)
    raise Error, 'not a valid public ssh key' unless status.success?

    bits, fingerprint, = stdout.split(' ', 3)
    { :length => bits.to_i, :fingerprint => format_fingerprint(fingerprint) }
  end

  # ssh-keygen prints the fingerprint prefixed with "SHA256:" and strips the
  # base64 padding. Restore the padding so the value stays stable across tools.
  def format_fingerprint(raw)
    encoded = raw.to_s.delete_prefix('SHA256:')
    encoded + ('=' * ((4 - (encoded.length % 4)) % 4))
  end
end
