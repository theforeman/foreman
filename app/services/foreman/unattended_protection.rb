module Foreman
  class UnattendedProtection
    CACHE_KEY_PREFIX = 'unattended_attempts_v1'
    ATTEMPT_WINDOW = 5.minutes

    attr_reader :request_ip

    def initialize(request_ip:)
      @request_ip = request_ip
    end

    def get_unattended_attempts
      return 0 unless request_ip.present?

      Rails.cache.read(cache_key, raw: true).to_i
    end

    def rate_limited?
      return false if request_ip.blank? || attempts_limit <= 0

      Rails.cache.fetch(cache_key, raw: true, expires_in: ATTEMPT_WINDOW, unless_exist: true) { 0 }
      return false if Rails.cache.increment(cache_key, 1, raw: true, expires_in: ATTEMPT_WINDOW).nil?

      get_unattended_attempts > attempts_limit
    end

    def log_rate_limited
      Rails.logger.warn("Unattended request limit exceeded from IP: #{request_ip}")
    end

    private

    def cache_key
      "#{CACHE_KEY_PREFIX}_#{request_ip}"
    end

    def attempts_limit
      Setting[:unattended_attempts_limit].to_i
    end
  end
end
