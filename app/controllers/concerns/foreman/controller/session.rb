module Foreman::Controller::Session
  extend ActiveSupport::Concern

  def session_expiry
    return if ignore_api_request?
    if session[:expires_at].blank? || (Time.at(session[:expires_at]).utc - Time.now.utc).to_i < 0
      session[:original_uri] = request.fullpath unless api_request?
      expire_session
    end
  rescue => e
    Foreman::Logging.exception("failed to determine if user sessions needs to be expired, expiring anyway", e)
    expire_session
  end

  # Backs up some state from a user's session around a supplied block, which
  # will usually expire or reset the session in some way
  def backup_session_content(keys = [:organization_id, :location_id, :original_uri, :sso_method])
    save_items = session.to_hash.slice(*keys.map(&:to_s)).symbolize_keys
    yield if block_given?
    session.update(save_items)
  end

  def update_activity_time
    return if ignore_api_request?
    set_activity_time
  end

  def set_activity_time
    session[:expires_at] = Setting[:idle_timeout].minutes.from_now.to_i
  end

  def expire_session
    logger.info "Session for #{User.current} is expired."
    backup_session_content { reset_session }
    if api_request?
      render :plain => '', :status => :unauthorized
    else
      sso = get_sso_method
      if sso.nil? || !sso.support_expiration?
        inline_warning _("Your session has expired, please login again")
        redirect_to main_app.login_users_path
      else
        redirect_to sso.expiration_url
      end
    end
  end

  # If an API is invoked from the UI, the session will include an :expires_at.
  # When :expires_at is received, it must be managed and the request denied
  # when an expiration has occurred; otherwise, it may be ignored.
  def ignore_api_request?
    api_request? && session[:expires_at].blank?
  end
end
