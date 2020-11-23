require_dependency 'facets'

module Facets
  module ManagedHostExtensions
    extend ActiveSupport::Concern
    include Facets::BaseHostExtensions

    included do
      configure_facet(:host, :host, :host_id) do |facet_config|
        include_in_clone facet_config.name
      end
    end
  end
end
