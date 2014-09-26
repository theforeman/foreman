class PasswordCrypt
  ALGORITHMS = {'MD5' => '$1$', 'SHA256' => '$5$', 'SHA512' => '$6$'}

  def self.passw_crypt(passwd, hash_alg = 'MD5')
    raise Foreman::Exception.new(N_("Unsupported password hash function '%s'"), hash_alg) unless ALGORITHMS.has_key?(hash_alg)
    passwd.crypt("#{ALGORITHMS[hash_alg]}#{SecureRandom.base64(6)}")
  end

  def self.grub2_passw_crypt(passw)
    self.passw_crypt(passw, 'MD5')
  end
end
