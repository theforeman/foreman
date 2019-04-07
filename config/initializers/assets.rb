module Webpack
  module Rails
    class Manifest
      class << self
        attr_writer :manifest
      end
    end
  end
end

# Be sure to restart your server when you modify this file.
Foreman::Application.configure do |app|
  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  # Rails.application.config.assets.precompile += %w( search.js )

  #  config.assets.precompile += %w()
  javascript = %w(compute_resource
                  compute_resources/libvirt/nic_info
                  compute_resources/ovirt/nic_info
                  compute_resources/vmware/nic_info
                  lookup_keys
                  host_edit
                  host_edit_interfaces
                  hosts
                  reports
                  spice
                  charts
                  taxonomy_edit
                  gettext/all
                  filters
                  subnets
                  hidden_values
                  proxy_status
                  about
                  parameter_override)

  javascript += FastGettext.default_available_locales.map { |loc| "locale/#{loc}/app" }

  stylesheets = %w(unimported/email.css)

  images = %w(editable/clear.png patternfly/bg-modal-about-pf.png)

  # Add the fonts path
  config.assets.paths << Rails.root.join('vendor', 'assets', 'fonts')

  # Precompile additional assets
  config.assets.precompile << /\.(?:svg|eot|woff|woff2|gif|ttf)$/
  config.assets.precompile += javascript.map { |js| js + '.js' } + stylesheets + images

  # Adds plugin assets to the application digests hash if a manifest file exists for a plugin
  config.after_initialize do
    if (manifest_file = Dir.glob("#{Rails.root}/public/assets/.sprockets-manifest*.json").first)
      foreman_manifest = JSON.parse(File.read(manifest_file))

      Foreman::Plugin.all.each do |plugin|
        # Manifests may be stored under the engine installation or under the Foreman app root, then
        # either with just the plugin name or with hyphens replaced with underscores.
        possible_manifests = [plugin.path, app.root].map do |root_dir|
          [File.join(root_dir, "public/assets/#{plugin.id}/#{plugin.id}.json"),
           File.join(root_dir, "public/assets/#{plugin.id.to_s.tr('-', '_')}/#{plugin.id.to_s.tr('-', '_')}.json")]
        end.flatten

        if (manifest_path = possible_manifests.detect { |path| File.file?(path) })
          Rails.logger.debug { "Loading #{plugin.id} precompiled asset manifest from #{manifest_path}" }
          assets = JSON.parse(File.read(manifest_path))

          foreman_manifest['files']  = foreman_manifest['files'].merge(assets['files'])
          foreman_manifest['assets'] = foreman_manifest['assets'].merge(assets['assets'])
        end
      end

      manifest_filename = 'asset_manifest.json'
      tmp_path          = "#{Rails.root}/tmp"

      Tempfile.open(manifest_filename, tmp_path) do |file|
        file.write(foreman_manifest.to_json)
        app.assets_manifest              = Sprockets::Manifest.new(app.assets, file.path)
        ActionView::Base.assets_manifest = app.assets_manifest
      end
    end

    # When the dev server is enabled, this static manifest file is ignored and
    # always retrieved from the dev server.
    #
    # Otherwise we need to combine all the chunks from the various webpack
    # manifests. This is the main foreman manifest and all plugins that may
    # have one. We then store this in the webpack-rails manifest using our
    # monkey patched function.
    unless config.webpack.dev_server.enabled
      if (webpack_manifest_file = Dir.glob("#{Rails.root}/public/webpack/manifest.json").first)
        webpack_manifest = JSON.parse(File.read(webpack_manifest_file))

        Foreman::Plugin.with_webpack.each do |plugin|
          manifest_path = plugin.webpack_manifest_path
          next unless manifest_path

          Rails.logger.debug { "Loading #{plugin.id} webpack asset manifest from #{manifest_path}" }
          assets = JSON.parse(File.read(manifest_path))

          plugin_id = plugin.id.to_s
          assets['assetsByChunkName'].each do |chunk, filename|
            if chunk == plugin_id || chunk.start_with?("#{plugin_id}:")
              webpack_manifest['assetsByChunkName'][chunk] = filename
            end
          end
        end

        Webpack::Rails::Manifest.manifest = webpack_manifest
      end
    end
  end
end
