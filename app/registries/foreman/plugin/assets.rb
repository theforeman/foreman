module Foreman
  class Plugin
    module Assets
      attr_reader :assets

      def initialize(id)
        super
        @assets = []
        @automatic_assets = true
      end

      def after_initialize
        super
        precompile_assets(*find_assets(path)) if @automatic_assets
        register_assets
      end

      def precompile_assets(*assets)
        @assets.push(*assets)
      end

      # Controls automatic searching of plugin_root/app/assets/
      # Disable when assets are combined and only some need to be precompiled
      def automatic_assets(enabled)
        @automatic_assets = !!enabled
      end

      def webpack_manifest_path
        manifest_path = File.join(path, 'public', 'webpack', id.to_s, 'manifest.json')
        File.file?(manifest_path) ? manifest_path : nil
      end

      def uses_webpack?
        path && (File.file?(File.join(path, 'webpack', 'index.js')) || webpack_manifest_path.present?)
      end

      private

      def find_assets(root)
        return [] unless root.present? && Dir.exist?(root)

        present_assets = Dir.chdir(root) do
          Dir["app/assets/**/*"].select { |f| File.file?(f) }.map { |f| f.split(File::SEPARATOR, 4).last }
        end
        new_assets = present_assets - assets

        # Assets outside of the namespace can't properly be packaged, so don't
        # automatically detect and include them. Requires manual configuration
        # to use this unsupported layout.
        new_assets, outside_prefix = new_assets.partition do |p|
          p.start_with?("#{id}/") || p.start_with?("#{id.to_s.tr('-', '_')}/")
        end

        if outside_prefix.present?
          Rails.logger.debug "Plugin #{id} has assets outside of its namespace, these will be ignored: #{outside_prefix.join(', ')}"
        end

        new_assets
      end

      def register_assets
        return unless assets.present?
        Rails.logger.debug { "Registering #{assets.count} assets for plugin #{id} precompilation" }
        Rails.application.config.assets.precompile.push(*assets)
      end
    end
  end
end
