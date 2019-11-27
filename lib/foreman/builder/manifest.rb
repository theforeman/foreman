require 'net/http'
require 'uri'

require 'foreman/plugin'

module Foreman
  module Builder
    class Manifest
      # Raised if we can't read our builder manifest for whatever reason
      class ManifestLoadError < StandardError
        def initialize(message, orig)
          super "#{message} (original error #{orig})"
        end
      end

      # Raised if tfm-builder couldn't build one of your entry points
      class BuilderError < StandardError
        def initialize(errors)
          super "Error in @theforeman/builder, details follow below:\n#{errors.join("\n\n")}"
        end
      end

      # Raised if a supplied entry point does not exist in the builder manifest
      class EntryPointMissingError < StandardError
      end

      class << self
        def asset_paths(source)
          raise BuilderError, manifest["errors"] unless manifest_bundled?

          paths = manifest["assetsByChunkName"][source]
          if paths
            # Can be either a string or an array of strings.
            # Do not include source maps as they are not javascript
            [paths].flatten.reject { |p| p =~ /.*\.map$/ }.map do |p|
              "/#{::Rails.configuration.webpack.public_path}/#{p}"
            end
          else
            raise EntryPointMissingError, "Can't find entry point '#{source}' in manifest.json"
          end
        end

        private

        def manifest_bundled?
          !manifest["errors"].any? { |error| error.include? "Module build failed" }
        end

        def manifest
          if ::Rails.configuration.webpack.dev_server.enabled
            # Don't cache if we're in dev server mode, manifest may change ...
            load_manifest
          else
            # ... otherwise cache at class level, as JSON loading/parsing can be expensive
            @manifest ||= load_manifest
          end
        end

        def load_manifest
          if ::Rails.configuration.webpack.dev_server.enabled
            load_dev_server_manifest
          else
            load_static_manifest
          end
        end

        def load_dev_server_manifest
          host = ::Rails.configuration.webpack.dev_server.host
          host = instance_eval(&host) if host.respond_to?(:call)
          port = ::Rails.configuration.webpack.dev_server.port
          http = Net::HTTP.new(host, port)
          http.use_ssl = ::Rails.configuration.webpack.dev_server.https
          http.verify_mode = ::Rails.configuration.webpack.dev_server.https_verify_peer ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
          data = http.get(dev_server_path).body
          
          JSON.parse(data)
        rescue => e
          raise ManifestLoadError.new("Could not load manifest from webpack-dev-server at http://#{host}:#{port}#{dev_server_path} - is it running, and is stats-webpack-plugin loaded?", e)
        end

        def load_static_manifest
          # load the main manifest
          Rails.logger.debug { "Loading webpack asset manifest from #{static_manifest_path}" }
          manifest = JSON.parse(File.read(static_manifest_path))

          # load plugin manifests
          Foreman::Plugin.with_webpack.each do |plugin|
            plugin_manifest = load_plugin_static_manifest plugin
            next unless plugin_manifest.present?

            plugin_manifest['assetsByChunkName'].each do |chunk, files|
              manifest['assetsByChunkName'][chunk] = files
            end
          end
          
          manifest
        rescue => e
          raise ManifestLoadError.new("Could not load compiled manifest from #{static_manifest_path} - have you run `rake webpack:compile`?", e)
        end
        
        def load_plugin_static_manifest plugin
          manifest_path = plugin.webpack_manifest_path
          return nil unless manifest_path.present?

          Rails.logger.debug { "Loading #{plugin.id} webpack asset manifest from #{manifest_path}" }
          JSON.parse(File.read(manifest_path))
        rescue => e
          raise ManifestLoadError.new("Could not load compiled manifest from #{manifest_path}", e)
        end

        def static_manifest_path
          ::Rails.root.join(
            ::Rails.configuration.webpack.output_dir,
            ::Rails.configuration.webpack.manifest_filename
          )
        end

        def dev_server_path
          "/#{::Rails.configuration.webpack.public_path}/#{::Rails.configuration.webpack.manifest_filename}"
        end

        def dev_server_url
          "http://#{::Rails.configuration.webpack.dev_server.host}:#{::Rails.configuration.webpack.dev_server.port}#{dev_server_path}"
        end
      end
    end
  end
end
