# config/initializers/rabl_init.rb
require 'rabl'

module Rabl
  class Configuration
    attr_accessor :use_controller_name_as_json_root
    attr_accessor :json_root_default_name
  end
end

module Foreman
  module RablEngineExt
    def api_version
      respond_to?(:response) ? response.headers["Foreman_api_version"] : '2'
    end

    def default_options
      {:root => false, :object_root => false}
    end

    def collection(data, options = default_options)
      super(data, options)
    end

    # extending this helper defined in module Rabl::Helpers allows users to
    # overwrite the object root name in show rabl views.  Two options:
    # 1) no root - default
    # 2) custom  - pass ?params[:root_name]=custom_name in URL
    def data_name(data_token)
      # custom object root
      return params['root_name'] if respond_to?(:params) && params['root_name'].present? && !['false', false].include?(params['root_name'])
    end
  end
end
Rabl::Engine.send(:prepend, Foreman::RablEngineExt)

Rabl.configure do |config|
  # Commented as these are defaults
  # config.cache_all_output = false
  # config.cache_sources = Rails.env != 'development' # Defaults to false
  # config.cache_engine = Rabl::CacheEngine.new # Defaults to Rails cache
  # config.perform_caching = false
  # config.escape_all_output = false
  # config.json_engine = nil # Class with #dump class method (defaults JSON)
  # config.msgpack_engine = nil # Defaults to ::MessagePack
  # config.bson_engine = nil # Defaults to ::BSON
  # config.plist_engine = nil # Defaults to ::Plist::Emit
  # config.include_json_root = true
  # config.include_msgpack_root = true
  # config.include_bson_root = true
  # config.include_plist_root = true
  # config.include_xml_root  = false
  # config.include_child_root = true
  # config.enable_json_callbacks = false
  # config.xml_options = { :dasherize  => true, :skip_types => false }
  config.view_paths << Rails.root.join('app', 'views')
  # config.raise_on_missing_attribute = true # Defaults to false
  # config.replace_nil_values_with_empty_strings = true # Defaults to false
  config.use_controller_name_as_json_root = false
  config.json_root_default_name = :results #used only if use_controller_name_as_json_root = false
end
