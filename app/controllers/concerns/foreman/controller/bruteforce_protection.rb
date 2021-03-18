module Foreman::Controller::BruteforceProtection
  extend ActiveSupport::Concern

  included do
    delegate :count_login_failure, :get_login_failures, :log_bruteforce, to: :bruteforce_protection
  end

  def bruteforce_attempt?
    session[:user].nil? && bruteforce_protection.bruteforce_attempt?
  end

  private

  def bruteforce_protection
    ::Foreman::BruteforceProtection.new(
      request_ip: request.remote_ip
    )
  end
end
