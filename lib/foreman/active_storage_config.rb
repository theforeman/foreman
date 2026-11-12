module Foreman
  class ActiveStorageConfig
    SUPPORTED_SERVICES = [:local, :s3].freeze

    def initialize(settings)
      @settings = settings.fetch(:active_storage, {})
    end

    def service
      service = @settings.fetch(:service, :local).to_s.strip.to_sym
      unless SUPPORTED_SERVICES.include?(service)
        raise ArgumentError, "Unsupported Active Storage service: #{service}"
      end

      validate_s3! if service == :s3
      service
    end

    private

    def validate_s3!
      settings = @settings.fetch(:s3, {})
      missing = [:bucket, :region].select { |key| settings[key].to_s.strip.empty? }
      if missing.any?
        raise ArgumentError, "Missing Active Storage S3 settings: #{missing.join(', ')}"
      end

      access_key = settings[:access_key_id].to_s.strip
      secret_key = settings[:secret_access_key].to_s.strip
      return if access_key.empty? == secret_key.empty?

      raise ArgumentError, 'Active Storage S3 access key and secret key must be configured together'
    end
  end
end
