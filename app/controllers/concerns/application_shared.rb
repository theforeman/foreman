module ApplicationShared
  extend ActiveSupport::Concern

  include Foreman::Controller::MigrationChecker
  include Foreman::Controller::Authentication
  include Foreman::Controller::Session
  include Foreman::Controller::TopbarSweeper
  include Foreman::ThreadSession::Cleaner
  include FindCommon

  def set_timezone
    default_timezone = Time.zone
    client_timezone  = User.current.try(:timezone) || cookies[:timezone]
    Time.zone        = client_timezone if client_timezone.present?
    yield
  ensure
    # Reset timezone for the next thread
    Time.zone = default_timezone
  end

  def current_permission
    [action_permission, controller_permission].join('_')
  end
end
