module HostAspects
  class Configuration
    def registered_aspects
      aspects_registry.dup
    end

    def register(aspect_name, aspect_model = nil, &block)
      entry = Entry.new(aspect_name, aspect_model)

      entry.instance_eval(&block) if block_given?

      aspects_registry[entry.name] = entry
    end

    def definition_for(aspect_instance)
      instance_sym = aspect_instance.class.model_name.singular.to_sym

      aspects_registry.find { |_k, entry| entry.model == instance_sym }
    end

    private

    attr_writer :aspects_registry

    def aspects_registry
      @aspects_registry ||= {}
    end
  end
end