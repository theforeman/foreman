module Foreman
  class ForceSsl
    UNATTENTED_PATHS = %r{^/(unattended|userdata)/}

    def self.allowed_http_actions
      @allowed_http_actions ||= []
    end

    def self.add_allowed_http_action!(action)
      allowed_http_actions << action
    end

    def initialize(request)
      @request = request
    end

    def allows_http?
      !requires_ssl?
    end

    def requires_ssl?
      unattended_path? ? unattended_ssl? : !path_allows_http?
    end

    private

    def path_allows_http?
      self.class.allowed_http_actions.any? do |action|
        allowed_path = path_for_action(action)
        @request.path_info.starts_with?(allowed_path)
      end
    end

    def unattended_path?
      @request.path_info.match?(UNATTENTED_PATHS)
    end

    def unattended_ssl?
      unattended_preview? || URI.parse(Setting[:unattended_url]).scheme == 'https'
    end

    def unattended_preview?
      @request.params.key?('spoof') || @request.params.key?('hostname')
    end

    def path_for_action(action)
      Rails.application.routes.url_helpers.url_for(action.merge(only_path: true))
    end
  end
end
