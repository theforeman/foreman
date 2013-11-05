module Foreman::Controller::Authentication
  extend ActiveSupport::Concern

  def available_sso
    @available_sso ||= SSO.get_available(self)
  end

  def authenticate
    return true if (User.current && Rails.env.test? && api_request?) ||
                   session[:user] && (User.current = User.unscoped.find(session[:user]))

    if SETTINGS[:login]
      # authentication is enabled
      user = sso_authentication

      if user.is_a?(User)
        logger.info("Authorized user #{user.login}(#{user.to_label})")
        User.current = user
        session[:user] = User.current.id unless api_request?
        return User.current.present?
      else
        if api_request?
          false
        else
          # Keep the old request uri that we can redirect later on
          session[:original_uri] = request.fullpath
          @available_sso ||= SSO::Base.new(self)

          (redirect_to @available_sso.login_url and return) unless @available_sso.has_rendered
        end

      end

    else
      # We assume we always have a user logged in, if authentication is disabled, the user is the built-in admin account.
      User.current = User.admin
      session[:user] = User.current.id unless api_request?
    end
  end

  def authorized
    User.current.allowed_to?(
      :controller => params[:controller].gsub(/::/, "_").underscore,
      :action     => params[:action])
  end

  def require_login
    authenticate
  end

  def is_admin?
    return true unless SETTINGS[:login]
    return true if User.current && User.current.admin?
    User.current = sso_authentication || (return false)
    return User.current.admin? if User.current
    return false
  end

  def sso_authentication
    if available_sso.present?
      if available_sso.authenticated?
        user = User.unscoped.find_by_login(available_sso.user)
        update_activity_time unless api_request?
      elsif available_sso.support_login?
        available_sso.authenticate!
      else
        logger.warn("SSO failed")
        if available_sso.support_fallback? && !available_sso.has_rendered
          logger.warn("falling back to login form")
          available_sso.has_rendered = true
          redirect_to login_users_path
        end
      end
    end

    user
  end

end

