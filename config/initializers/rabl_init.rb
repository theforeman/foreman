# config/initializers/rabl_init.rb
require 'rabl'

module Rabl
  class Configuration
    attr_accessor :use_controller_name_as_json_root
    attr_accessor :json_root_default_name
  end

  class Engine

    def api_version
      response.headers["Foreman_api_version"]
    end

    def default_options
      return {:root => false, :object_root => false} if api_version == '2'
      {}
    end

    def collection_with_defaults(data, options = default_options)
      collection_without_defaults(data, options)
    end
    alias_method_chain :collection, :defaults

    # extending this helper defined in module Rabl::Helpers allows users to
    # overwrite the object root name in show rabl views.  Three options:
    # 1) class name of object (ex. domain) (default behavior of rabl)
    # 2) no root - pass ?params[:object_name]=false in URL
    # 3) custom  - pass ?params[:object_name]=custom_name in URL
    def data_name(data_token)
      return nil if params['object_name'].to_s == 'false'
      return params['object_name'] if params['object_name'].present?
      super
    end

  end
end

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
  # config.view_paths = []
  # config.raise_on_missing_attribute = true # Defaults to false
  # config.replace_nil_values_with_empty_strings = true # Defaults to false
  config.use_controller_name_as_json_root = false
  config.json_root_default_name = :results  #used only if use_controller_name_as_json_root = false
end
