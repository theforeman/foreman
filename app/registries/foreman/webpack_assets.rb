module Foreman
  module WebpackAssets
    def bundle_name(plugin_name)
      plugin_name.to_s.gsub(/core$/, '').gsub(/-|_|#{remove_bundle_name_plugins}/,'')
    end

    def plugin_name_regexp
      /foreman*|katello*/
    end

    def remove_bundle_name_plugins
      /foreman*/
    end
  end
end
