module Facets
  class Entry
    attr_reader :name, :model

    Facets::SUPPORTED_CORE_OBJECTS.each do |core_object|
      define_method "has_#{core_object}_configuration?" do
        configuration_entries.key?(core_object)
      end

      define_method "#{core_object}_configuration" do
        configuration_entries[core_object] ||= send("configure_#{core_object}")
      end

      define_method "configure_#{core_object}" do |facet_model = nil, &block|
        facet_model ||= @model
        entry = Facets::HostBaseEntry.new(facet_model, @name)
        entry.instance_eval(&block) if block

        configuration_entries[core_object] = entry
      end
    end

    # readers
    delegate :helper, :extension,
      :api_single_view, :api_list_view,
      :api_param_group_description, :api_param_group, :api_controller,
      :tabs,
      :compatibility_properties, :dependent, to: :host_configuration
    # writers
    delegate :add_helper,
      :add_tabs,
      :extend_model,
      :api_view,
      :api_docs,
      :template_compatibility_properties,
      :set_dependent_action,
      to: :host_configuration

    def initialize(facet_model = nil, facet_name = nil)
      fail 'Either facet_name or facet_model should be not nil' if facet_name.nil? && facet_model.nil?
      facet_name ||= to_name(facet_model)

      @model = facet_model
      @name = facet_name
    end

    def has_configuration(config_type)
      if config_type.is_a? Array
        config_type.each do |config_type_instance|
          return true if configuration_entries.key?(config_type_instance)
        end
        false
      else
        configuration_entries.key?(config_type)
      end
    end

    def configuration_for(config_type)
      configuration_entries[config_type]
    end

    private

    def to_name(facet_model)
      facet_model.name.demodulize.underscore.to_sym
    end

    def configuration_entries
      @configuration_entries ||= {}
    end
  end
end
