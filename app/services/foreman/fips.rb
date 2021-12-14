module Foreman
  module Fips
    def self.md5_available?
      @md5_available ||=
        begin
          OpenSSL::Digest::MD5.digest('')
          true
        rescue OpenSSL::Digest::DigestError
          false
        end
    end
  end
end
