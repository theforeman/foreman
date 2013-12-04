module Menu
  module IsolatedRoutes
    extend ActiveSupport::Concern

      # Create route helper methods for each isolated engine similar to what is available in controllers and views loaded by ActionDispatch::Routing::RoutesProxy
      # def katello
      #   Katello.railtie_routes_url_helpers
      # end
      # ex.  link_to "Systems", katello.systems_path when called with main_app
      #
      Module.constants.each do |mod|
        next unless (mod.to_s.constantize && mod.to_s.constantize.const_defined?("Engine") && mod.to_s.constantize.respond_to?(:railtie_routes_url_helpers) rescue nil)
        if mod.to_s.constantize.const_defined?("Engine") && mod.to_s.constantize.respond_to?(:railtie_routes_url_helpers)
          define_method(mod.to_s.constantize::Engine.engine_name) do
              mod.to_s.constantize.railtie_routes_url_helpers
          end
        end
      end

      # Create main_app route helper methods similar to what is available in controllers and views loaded by ActionDispatch::Routing::RoutesProxy
      # ex. link_to "Hosts", main_app.hosts_path when called from isolated engine
      def main_app
        Rails.application.routes.url_helpers
      end

  end
end

