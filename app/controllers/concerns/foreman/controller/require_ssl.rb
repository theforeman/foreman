module Foreman
  module Controller
    module RequireSsl
      extend ActiveSupport::Concern

      included do
        force_ssl :if => :require_ssl?
      end

      protected

      def require_ssl?
        SETTINGS[:require_ssl]
      end

      def unattended_ssl?
        SETTINGS[:require_ssl] && URI.parse(Setting[:unattended_url]).scheme == 'https'
      end
    end
  end
end
