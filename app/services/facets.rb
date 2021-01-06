module Facets
  SUPPORTED_CORE_OBJECTS = [:host, :hostgroup]

  module_function

  def registered_facets(facet_type = nil)
    facets = configuration.dup
    return facets unless facet_type
    facets.select { |_, facet| facet.has_configuration(facet_type) }
  end

  def facets_for_type(facet_type)
    registered_facets(facet_type).map { |_, entry| entry.configuration_for(facet_type) }
  end

  def find_facet_by_class(facet_class, facet_type = :host)
    hash = registered_facets(facet_type).select { |_, facet| facet.configuration_for(facet_type).model == facet_class }
    hash.first
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
  def register(facet_model = nil, facet_name = nil, &block)
    if facet_model.is_a?(Symbol) && facet_name.nil?
      facet_name = facet_model
      facet_model = nil
    end

    entry = Facets::Entry.new(facet_model, facet_name)

    entry.instance_eval(&block) if block_given?

    # create host configuration if no block was specified
    entry.configure_host unless block_given?

    configuration[entry.name] = entry

    publish_entry_created(entry)
    # TODO MERGE
    #    Facets::ManagedHostExtensions.register_facet_relation(Host::Managed, entry)
    #    Facets::BaseHostExtensions.register_facet_relation(Host::Base, entry)

    entry
  end

  # subscription method to know when a facet entry is created.
  # The callback will receive a single parameter - the entry that was created.
  def after_entry_created(&block)
    entry_created_callbacks << block
  end

  # declare private module methods.
  class << self
    private

    def configuration
      @configuration ||= Hash[entries_from_plugins.map { |entry| [entry.name, entry] }]
    end

    def entries_from_plugins
      Foreman::Plugin.all.map { |plugin| plugin.facets }.compact.flatten
    end

    def entry_created_callbacks
      @entry_created_callbacks ||= []
    end

    def publish_entry_created(entry)
      entry_created_callbacks.each do |callback|
        callback.call(entry)
      end
    end
  end
end
