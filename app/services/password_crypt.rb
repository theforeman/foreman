require 'base64'

class PasswordCrypt
  ALGORITHMS = {'SHA256' => '$5$', 'SHA512' => '$6$', 'MD5' => '$1$', 'Base64' => ''}

  def self.passw_crypt(passwd, hash_alg = 'SHA256')
    raise Foreman::Exception.new(N_("Unsupported password hash function '%s'"), hash_alg) unless ALGORITHMS.has_key?(hash_alg)
    hash_alg == 'Base64' ? Base64.strict_encode64(passwd) : passwd.crypt("#{ALGORITHMS[hash_alg]}#{SecureRandom.base64(6)}")
  end

  def self.grub2_passw_crypt(passw)
    self.passw_crypt(passw, 'MD5')
  end

  def self.crypt_gnu_compatible?
    @crypt_gnu_compatible ||= passw_crypt("test_this").match('^\$\d+\$.+\$.+')
  end
end
