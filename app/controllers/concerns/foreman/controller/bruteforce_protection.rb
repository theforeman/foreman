module Foreman::Controller::BruteforceProtection
  extend ActiveSupport::Concern

  def count_login_failure
    Rails.cache.write("failed_login_#{request.ip}", get_login_failures+1, :expires_in => 5.minutes)
  end

  def get_login_failures
    Rails.cache.fetch("failed_login_#{request.ip}") {0} if request.ip.present?
  end

  def bruteforce_attempt?
    get_login_failures >= 30
  end

  def log_bruteforce
    logger.warn("Brute-force attempt blocked from IP: #{request.ip}")
  end
end
