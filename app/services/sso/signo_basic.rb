module SSO
  class SignoBasic < Base
    def available?
      controller.api_request? && http_auth_set? && Setting['signo_sso']
    end

    def authenticate!
      user = signo_auth
      self.user = user.login if user.present?
    end

    def authenticated?
      User.current.present? ? User.current.login : authenticate!
    end

    def http_auth_set?
      request.authorization.present? && request.authorization =~ /\ABasic/
    end

    private

    def signo_auth
      u, p = ActionController::HttpAuthentication::Basic.user_name_and_password(controller.request)
      uri  = URI.parse("#{Setting['signo_url']}/login.json?username=#{URI.escape(u)}&password=#{URI.escape(p)}")
      http = Net::HTTP.new(uri.system, uri.port)
      if uri.scheme == 'https'
        http.use_ssl     = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end
      request  = Net::HTTP::Post.new(uri.request_uri)
      response = http.request(request)
      response.kind_of?(Net::HTTPSuccess) ? User.find_by_login(u) : nil
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse,
        Net::HTTPHeaderSyntaxError, Net::ProtocolError, Errno::ECONNREFUSED => e
      Rails.logger.error "An error #{e.class} occured with message #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      return nil
    rescue OpenSSL::SSL::SSLError => e
      Rails.logger.error "An SSL error #{e.class} occured with message #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      return nil
    end

  end
end
