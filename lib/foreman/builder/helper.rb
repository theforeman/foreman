require 'action_view'
require 'foreman/builder/manifest'

module Foreman
  module Builder
    module Helper
      def builded_js_for source
        javascript_include_tag *webpack_asset_paths(source, :extension => 'js')
      end
      
      def builded_css_for source
        stylesheet_link_tag *webpack_asset_paths(source, :extension => 'css')
      end
      # Return builded asset paths for a particular entry point.
      #
      # Response may either be full URLs (eg http://localhost/...) if the dev server
      # is in use or a host-relative URl (eg /webpack/...) if assets are precompiled.
      #
      # Will raise an error if our manifest can't be found or the entry point does
      # not exist.
      def webpack_asset_paths(source, extension: nil)
        return "" unless source.present?

        paths = Foreman::Builder::Manifest.asset_paths(source)
        paths = paths.select { |p| p.ends_with? ".#{extension}" } if extension

        if ::Rails.configuration.webpack.dev_server.enabled
          port = ::Rails.configuration.webpack.dev_server.port
          protocol = ::Rails.configuration.webpack.dev_server.https ? 'https' : 'http'

          host = ::Rails.configuration.webpack.dev_server.host
          host = instance_eval(&host) if host.respond_to?(:call)
          
          paths.map! do |p|
            "#{protocol}://#{host}:#{port}#{p}"
          end
        end

        paths
      end
    end
  end
end
