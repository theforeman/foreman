require 'oauth/client/action_controller_request'

module SSO
  class Oauth < Base
    def available?
      controller.api_request? && !!(request.authorization =~ /^OAuth/)
    end

    def authenticate!
      unless Setting['oauth_active']
        Rails.logger.warn 'Trying to authenticate with OAuth, but OAuth is not active'
        return nil
      end

      unless (incoming_key = OAuth::RequestProxy.proxy(request).oauth_consumer_key) == Setting['oauth_consumer_key']
        Rails.logger.warn "oauth_consumer_key should be '#{Setting['oauth_consumer_key']}' but was '#{incoming_key}'"
        return nil
      end

      if OAuth::Signature.verify(request, :consumer_secret => Setting['oauth_consumer_secret'])
        user_name = request.headers['foreman_user']
        if Setting['oauth_map_users'] && user_name != 'admin'
          User.find_by_login(user_name).tap do |obj|
            Rails.logger.warn "Oauth: mapping to user '#{user_name}' failed" if obj.nil?
          end.login
        else
          User.admin.login
        end
      else
        Rails.logger.warn "OAuth signature verification failed."
        return nil
      end
    end

    def authenticated?
      self.user = User.current.present? ? User.current : authenticate!
    end
  end
end
