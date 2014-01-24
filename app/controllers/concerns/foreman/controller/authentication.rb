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
        set_current_user user
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
      # We assume we always have a user logged in
      # if authentication is disabled, the user is the built-in admin account
      set_current_user User.admin
    end
  end

  def authorized
    User.current.allowed_to?(params.slice(:controller, :action, :id))
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

  private

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

  def set_current_user(user)
    User.current = user
    Foreman::Controller::UsersMixin.set_current_taxonomies(user)

    # API access shouldn't modify the session, its authentication should be
    # stateless.  Other successful logins should create new session IDs.
    unless api_request?
      backup_session_content { reset_session }
      session[:user] = user.id
      update_activity_time
    end
    user.present?
  end


end
