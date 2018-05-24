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
    end
  end
end
