module Foreman
  class BruteforceProtection
    CACHE_KEY_PREFIX = 'failed_login_v2'
    FAILURE_WINDOW = 5.minutes

    attr_reader :request_ip

    def initialize(request_ip:)
      @request_ip = request_ip
    end

    def get_login_failures
      return 0 unless request_ip.present?

      Rails.cache.read(cache_key, raw: true).to_i
    end

    def count_login_failure
      return unless request_ip.present?

      # FileStore and MemoryStore only increment existing values. Fetching the
      # zero value first keeps the implementation working with every cache
      # backend supported by Foreman, while increment reduces lost updates when
      # multiple login attempts arrive concurrently.
      Rails.cache.fetch(cache_key, raw: true, expires_in: FAILURE_WINDOW, unless_exist: true) { 0 }
      Rails.cache.increment(cache_key, 1, raw: true, expires_in: FAILURE_WINDOW)
    end

    def bruteforce_attempt?
      failed_login_attempts_limit > 0 && get_login_failures >= failed_login_attempts_limit
    end

    def log_bruteforce
      Rails.logger.warn("Brute-force attempt blocked from IP: #{request_ip}")
    end

    private

    def cache_key
      "#{CACHE_KEY_PREFIX}_#{request_ip}"
    end

    def failed_login_attempts_limit
      @failed_login_attempts_limit ||= Setting[:failed_login_attempts_limit].to_i
    end
  end
end
