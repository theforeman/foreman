require 'securerandom'

module Foreman
  module Util
    # searches for binaries in predefined directories and user PATH
    # accepts a binary name and an array of paths to search first
    # if path is omitted will search only in user PATH
    def which(bin, *path)
      path += ENV['PATH'].split(File::PATH_SEPARATOR)
      path.flatten.uniq.each do |dir|
        dest = File.join(dir, bin)
        return dest if FileTest.file? dest and FileTest.executable? dest
      end
      return false
    rescue StandardError => e
      logger.warn e
      return false
    end

    # Generates a URL-safe token for use with Rails for signing cookies
    def secure_token
      SecureRandom.base64(96).tr('+/=', '-_*')
    end
  end
end
