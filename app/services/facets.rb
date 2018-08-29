module Facets
  module_function

  def registered_facets
    configuration.dup
  end

  # Registers a new facet. Specify a model class for facet's data.
  # You can optionally specify a name that will be used to create
  # the assotiation on the host object.
  # Use block to add more initialization code for the facet.
  # Example:
  #   Facets.register(ExampleFacet, :example_facet_relation) do
  #     extend_model ExampleHostExtensions
  #     add_helper ExampleFacetHelper
  #     add_tabs :example_tabs
  #     api_view :list => 'api/v2/example_facets/base', :single => 'api/v2/example_facets/single_host_view'
  #     template_compatibility_properties :environment_id, :example_proxy_id
  #   end
  # For more detailed description of the registration methods, see <tt>Facets::Entry</tt> documentation.
  def register(facet_model, facet_name = nil, &block)
    entry = Facets::Entry.new(facet_model, facet_name)

    entry.instance_eval(&block) if block_given?

    configuration[entry.name] = entry

    Facets::ManagedHostExtensions.register_facet_relation(Host::Managed, entry)
    Facets::BaseHostExtensions.register_facet_relation(Host::Base, entry)
    entry
  end

  # declare private module methods.
  class << self
    private

    def configuration
      @configuration ||= Hash[entries_from_plugins.map { |entry| [entry.name, entry]}]
    end

    def entries_from_plugins
      Foreman::Plugin.all.map {|plugin| plugin.facets}.compact.flatten
    end
  end
end
