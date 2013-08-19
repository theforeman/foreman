# config/initializers/rabl_init.rb
require 'rabl'
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
end

module Rabl
  class Engine

    # returns two nodes for each attr --> :attr_id and :attr_name
    # Ex. associated_attributes :domain, :hostgroup
    # generates two nodes for each {:domain_id => .., :domain_name => .., :hostgroup_id =>..,  :hostgroup_name => ..}
    def associated_attributes *attrs
      attrs.each do |a|
        if a.kind_of? Hash
          # Ex. {:hostgroup => :to_label} -->  call method_name :to_label on klass instance hostgroup
          #     Node is always hostgroup_name, not hostgroup_to_label.
          a.each do |klass, method_name|
            resource_id_and_name_nodes(klass, method_name) if show_node?(a)
          end
        elsif a.kind_of?(Symbol) || a.kind_of?(String)
          resource_id_and_name_nodes(a, :name) if show_node?(a)
        end
      end
    end
    alias_method :associated_attribute, :associated_attributes

    # returns two nodes for each attr --> :attr_ids and :attr_names
    # Ex. associated_collections :puppetclasses
    # generates two nodes {:puppetclass_ids => [..], :puppetclass_names => [..]}
    def associated_collections *attrs
      attrs.each do |a|
        if a.kind_of? Hash
          a.each do |klass, method_name|
            collection_ids_and_names_nodes(klass, method_name)
          end
        elsif a.kind_of?(Symbol) || a.kind_of?(String)
          collection_ids_and_names_nodes(a, :name)
        end
      end
    end
    alias_method :associated_collection, :associated_collections

    # don't show nodes location_id, location_name if SETTINGS[:locations_enabled] is false.  Same for organizations.
    def show_node?(a)
      ![:location, :organization].include?(a) || (a == :location && SETTINGS[:locations_enabled]) || (a == :organization && SETTINGS[:organizations_enabled])
    end

    # helper method for #associated_attributes
    def resource_id_and_name_nodes(klass, method_name)
      attribute klass.to_s+'_id'

      node_name = klass.to_s+'_name'
      node(node_name) do |obj|
        obj.send(klass).try(method_name)
      end
    end

    # helper method for #associated_collections
    def collection_ids_and_names_nodes(klass, method_name)
      attribute klass.to_s.tableize.singularize+'_ids'

      node_name = klass.to_s.singularize+'_names'
      node(node_name) do |obj|
        obj.send(klass.to_s.tableize).collect{|a| a.try(method_name) }
      end
    end

  end
end
