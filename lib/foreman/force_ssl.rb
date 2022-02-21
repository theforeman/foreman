module Foreman
  class ForceSsl
    UNATTENTED_PATHS = %r{^/(unattended|userdata)/}

    def initialize(request)
      @request = request
    end

    def allows_http?
      !requires_ssl?
    end

    def requires_ssl?
      unattended_path? ? unattended_ssl? : true
    end

    private

    def unattended_path?
      @request.path_info.match?(UNATTENTED_PATHS)
    end

    def unattended_ssl?
      unattended_preview? || URI.parse(Setting[:unattended_url]).scheme == 'https'
    end

    def unattended_preview?
      @request.params.key?('spoof') || @request.params.key?('hostname')
    end
  end
end
