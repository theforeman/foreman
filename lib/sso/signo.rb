module SSO
  class Signo < Base
    attr_reader :env, :headers
    delegate :env, :to => :request
    delegate :headers, :session, :root_url, :to => :controller

    def available?
      Setting['signo_sso'] && defined?(Rack::OpenID) && !controller.api_request?
    end

    # by default we support login however when @failed flag is set it means that first try
    # of #authenticate! failed and we don't to try it again, because we would encounter
    # endless loop
    def support_login?
      !@failed
    end

    def support_expiration?
      true
    end

    def authenticated?
      if (response = env[Rack::OpenID::RESPONSE])
        store if (result = parse_open_id(response))
        result
      else
        false
      end
    end

    def authenticate!
      if (username = request.cookies['username'])
        # we already have cookie
        identifier                  = "#{Setting['signo_url']}/user/#{username}"
        headers['WWW-Authenticate'] = Rack::OpenID.build_header({ :identifier => identifier })
        controller.render :text => '', :status => 401
      else
        # we have no cookie yet so we plain redirect to OpenID provider to login
        controller.redirect_to login_url
      end
    end

    def login_url
      "#{Setting['signo_url']}?return_url=#{URI.escape(request.url)}"
    end

    def logout_url
      "#{Setting['signo_url']}/logout?return_url=#{URI.escape(root_url)}"
    end

    def expiration_url
      "#{login_url}&notice=expired"
    end

    private

    def store
      session[:sso_method] = self.class.to_s
    end

    def parse_open_id(response)
      case response.status
        when :success
          self.user = response.identity_url.split('/').last
          return true
        else
          Rails.logger.debug response.respond_to?(:message) ? response.message : "OpenID authentication failed: #{response.status}"
          @failed = true
          return false
      end
    end
  end
end
