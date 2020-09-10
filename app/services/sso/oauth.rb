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
        if Setting['oauth_map_users']
          user_name = request.headers['HTTP_FOREMAN_USER'].to_s
          User.unscoped.find_by_login(user_name).tap do |obj|
            Rails.logger.warn "Oauth: mapping to user '#{user_name}' failed" if obj.nil?
          end.try(:login)
        else
          User::ANONYMOUS_API_ADMIN
        end
      else
        Rails.logger.warn "OAuth signature verification failed."
        nil
      end
    end

    def authenticated?
      self.user = User.current.presence || authenticate!
    end

    def current_user
      if Setting['oauth_map_users']
        super
      elsif user == User::ANONYMOUS_API_ADMIN
        User.anonymous_api_admin
      end
    end
  end
end
