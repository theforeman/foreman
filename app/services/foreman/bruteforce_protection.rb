module Foreman
  class BruteforceProtection
    attr_reader :request_ip

    def initialize(request_ip:)
      @request_ip = request_ip
    end

    def get_login_failures
      Rails.cache.fetch("failed_login_#{request_ip}") { 0 } if request_ip.present?
    end

    def count_login_failure
      Rails.cache.write("failed_login_#{request_ip}", get_login_failures + 1, expires_in: 5.minutes)
    end

    def bruteforce_attempt?
      failed_login_attempts_limit > 0 && get_login_failures >= failed_login_attempts_limit
    end

    def log_bruteforce
      Rails.logger.warn("Brute-force attempt blocked from IP: #{request_ip}")
    end

    private

    def failed_login_attempts_limit
      @failed_login_attempts_limit ||= Setting[:failed_login_attempts_limit].to_i
    end
  end
end
