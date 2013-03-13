class Sso
  class Signo < Base
    attr_reader :env, :headers

    def initialize(controller)
      super
      @env = request.env
      @headers = controller.headers
    end

    def available?
      Setting['signo_sso']
    end

    def support_login?
      true
    end

    def support_logout?
      true
    end

    def logout_path
      "#{Setting['signo_url']}/logout?return_url="
    end

    def authenticated?
      if (response = env[Rack::OpenID::RESPONSE])
        parse_open_id(response)
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
        controller.redirect_to "#{Setting['signo_url']}?return_url=#{URI.escape(request.url)}"
      end
    end

    private

    def parse_open_id(response)
      case response.status
        when :success
          self.user = response.identity_url.split('/').last
          return true
        else
          Rails.logger.debug response.respond_to?(:message) ? response.message : "OpenID authentication failed: #{response.status}"
          return false
      end
    end
  end
end