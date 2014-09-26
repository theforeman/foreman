class PasswordCrypt
  MD5 = "$1$"
  SHA256 = "$5$"
  SHA512 = "$6$"

  def self.MD5?(encrypted_passwd)
    encrypted_passwd.start_with(PasswordCrypt::MD5)
  end

  def self.id
    case Setting[:password_hash]
      when 'SHA-256'
        PasswordCrypt::SHA256
      when 'SHA-512'
        PasswordCrypt::SHA512
      else
        PasswordCrypt::MD5
    end
  end

  def self.crypt(passwd)
    passwd.crypt("#{self.id}#{SecureRandom.base64(6)}")
  end
end