module Facets
  class Configuration
    def registered_facets
      facets_registry.dup
    end

    def register(facet_name, facet_model = nil, &block)
      entry = Entry.new(facet_name, facet_model)

      entry.instance_eval(&block) if block_given?

      facets_registry[entry.name] = entry

      Facets::ManagedHostExtensions.register_facet_relation(Host::Managed, entry)
    end

    def definition_for(facet_instance)
      instance_sym = facet_instance.class.model_name.singular.to_sym

      facets_registry.find { |_k, entry| entry.model == instance_sym }
    end

    private

    attr_writer :facets_registry

    def facets_registry
      @facets_registry ||= {}
    end
  end
end
