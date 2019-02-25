module Foreman::Controller::Authentication
  extend ActiveSupport::Concern

  def available_sso
    @available_sso ||= SSO.get_available(self)
  end

  def authenticate
    return true if (User.current && Rails.env.test? && api_request?) ||
                   session[:user] && (User.current = User.unscoped.find_by(id: session[:user]))

    user = sso_authentication

    if user.is_a?(User)
      logger.info("Authorized user #{user.login}(#{user.to_label})")
      set_current_user user
    else
      return false if api_request?
      # Keep the old request uri that we can redirect later on
      session[:original_uri] = request.fullpath
      @available_sso ||= SSO::Base.new(self)
      if session[:user] && !User.current
        backup_session_content { reset_session }
        warning _('Your session has expired, please login again')
      end
      return if @available_sso.has_rendered
      redirect_to @available_sso.login_url
    end
  end

  def authorized
    User.current.allowed_to?(path_to_authenticate)
  end

  def path_to_authenticate
    Foreman::AccessControl.normalize_path_hash(params.slice(:controller, :action, :id, :user_id))
  end

  def require_login
    authenticate
  end

  def is_admin?
    return true if User.current&.admin?
    User.current = sso_authentication || (return false)
    return User.current.admin? if User.current
    false
  end

  private

  def sso_authentication
    if available_sso.present?
      if available_sso.authenticated?
        user = available_sso.current_user
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

  def set_current_user(user)
    User.current = user

    # API access resets the whole session and marks the session as initialized from API
    # such sessions aren't checked for CSRF
    # UI access resets only session ID
    if api_request?
      reset_session
      session[:user] = user.id
      session[:api_authenticated_session] = true
      set_activity_time
    else
      backup_session_content { reset_session }
      session[:user] = user.id
      update_activity_time
    end
    user.present?
  end
end
