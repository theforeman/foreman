require 'base64'

class PasswordCrypt
  ALGORITHMS = {'SHA256' => '$5$', 'SHA512' => '$6$', 'Base64' => '', 'Base64-Windows' => ''}

  if Foreman::Fips.md5_available?
    ALGORITHMS['MD5'] = '$1$'
  end

  def self.generate_linux_salt
    # Linux crypt accepts maximum 16 [a-zA-Z0-9./] characters, on Ruby 2.5+ use alphanumeric
    # method, on older rubies let's use safe base64 downgraded to base63
    SecureRandom.respond_to?(:alphanumeric) ? SecureRandom.alphanumeric(16) : SecureRandom.base64(12).tr('+=', '..')
  end

  def self.passw_crypt(passwd, hash_alg = 'SHA256')
    raise Foreman::Exception.new(N_("Unsupported password hash function '%s'"), hash_alg) unless ALGORITHMS.has_key?(hash_alg)

    case hash_alg
    when 'Base64'
      result = Base64.strict_encode64(passwd)
    when 'Base64-Windows'
      result = Base64.strict_encode64(passwd.concat("AdministratorPassword").encode('utf-16le'))
    else
      result = passwd.crypt("#{ALGORITHMS[hash_alg]}#{generate_linux_salt}")
    end

    result.force_encoding(Encoding::UTF_8) if result.encoding != Encoding::UTF_8
    result
  end

  def self.grub2_passw_crypt(passw)
    passw_crypt(passw, 'SHA512')
  end

  def self.crypt_gnu_compatible?
    @crypt_gnu_compatible ||= passw_crypt("test_this").match('^\$\d+\$.+\$.+')
  end
end
