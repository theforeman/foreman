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
        precompile_assets(*assets_from_settings(id))
        precompile_assets(*assets_from_settings(id.to_s.gsub('-', '_').to_sym))
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

      private

      def find_assets(root)
        return [] unless root.present? && Dir.exist?(root)

        assets = Dir.chdir(root) do
          Dir["app/assets/**/*"].select { |f| File.file?(f) }.map { |f| f.split(File::SEPARATOR, 4).last }
        end

        # Assets outside of the namespace can't properly be packaged, so don't
        # automatically detect and include them. Requires manual configuration
        # to use this unsupported layout.
        assets, outside_prefix = assets.partition { |p| p.start_with?("#{id}/") }
        if outside_prefix.present?
          Rails.logger.warn "Plugin #{id} has assets outside of its namespace, these will be ignored: #{outside_prefix.join(', ')}"
        end

        assets
      end

      # Call any initializers that configure SETTINGS for the plugin:assets:precompile
      # rake task and migrate the data.
      def assets_from_settings(id)
        Rails.application.initializers.detect { |i| i.name.to_s == "#{id}.configure_assets" }.try!(:run)
        assets = SETTINGS[id].try!(:[], :assets).try!(:[], :precompile)
        if assets
          Foreman::Deprecation.deprecation_warning('1.18', "Plugin #{id} must register assets via precompile_assets, not SETTINGS[:#{id}]")
          SETTINGS[id].delete(:assets)
        end
        assets
      end

      def register_assets
        return unless self.assets.present?
        Rails.logger.debug { "Registering #{self.assets.count} assets for plugin #{id} precompilation" }
        Rails.application.config.assets.precompile.push(*self.assets)
      end
    end
  end
end
