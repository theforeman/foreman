# Configure the environment to use non-MD5 hashing algorithms, as they are
# disabled in FIPS mode

require 'digest/sha1'
ActiveSupport::Digest.hash_digest_class = ::Digest::SHA1
