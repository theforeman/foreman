require 'facets'

module Facets
  module ManagedHostExtensions
    extend ActiveSupport::Concern

    included do
      include Facets::BaseHostExtensions
      configure_facet(:host, :host, :host_id) do |facet_config|
        include_in_clone facet_config.name
      end
      refresh_facet_relations

      Facets.after_entry_created do |entry|
        register_facet_relation(entry) if entry.has_host_configuration?
      end
    end
  end
end
