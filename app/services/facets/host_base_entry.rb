module Facets
  class HostBaseEntry
    attr_reader :name, :model, :helper, :extension,
      :api_single_view, :api_list_view,
      :api_param_group_description, :api_param_group, :api_controller,
      :tabs,
      :compatibility_properties, :dependent

    def initialize(facet_model, facet_name)
      @compatibility_properties = []
      facet_name ||= to_name(facet_model)

      @model = facet_model
      @name = facet_name
    end

    # Declare a helper module that will be added to host's view.
    def add_helper(facet_helper)
      @helper = facet_helper
    end

    # Declare additional tabs to host's single view.
    # The value can be either a static hash or a symbol for method specified in helper.
    # The hash should be in form:
    #   :tab_identifier => value_to_show_in_tab
    # later on, the framework will pass the value to +render+:
    #   render(val, :f => host_form)
    def add_tabs(tabs)
      @tabs = tabs
    end

    # Specify <tt>ActiveSupport::Concern</tt> to extend the host model
    def extend_model(extension_class)
      @extension = extension_class
    end

    # Specify changes to api view templates using this method
    # view_templates is a Hash with two keys:
    # [+:single+] the value is a path to +.rabl+ file that will be used in single host rabl template.
    # [+:list+] the value is a path to +.rabl+ file that will be used in hosts list rabl template.
    # each template is called in context of the host object:
    #   partial('value/from/the/hash', :object => @host)
    # Any +attributes+ statements will be added to the host object. It is advised to create a separate
    # node under the host, and put all the relevant values under it.
    # Examle for the template:
    #
    #   node :example_facet do
    #     partial("api/v2/example_facets/base", :object => @host.example_facet)
    #   end
    def api_view(view_templates)
      @api_single_view = view_templates[:single]
      @api_list_view = view_templates[:list]
    end

    # Add API documentation extensions for describing host's create and update parameters.
    # We are using apipie's ability to specify external param_groups.
    # New Hash parameter is added to host with id in form of: "#{facet_name}_attributes",
    # The content of the node will be described by using param_group specified in +controller+
    # with id specified in +param_group+. There is also an option to specify custom description
    # for the whole "#{facet_name}_attributes"
    def api_docs(param_group, controller, description = nil)
      @api_param_group = param_group
      @api_controller = controller
      @api_param_group_description = description
    end

    # Use this method to maintain compatibility with older versions of foreman templates. Every property that
    # will be set here, will get a forwarder method in host, so the property will still be available for templates.
    # Example:
    # Let's say we have example_facet, that defines :foo property.
    # # Initialization:
    #  Facets.register(ExampleFacet) do
    #     template_compatibility_properties :foo
    #  end
    # ---
    # # Template:
    #  host.build_example_facet(:foo => 'bar')
    #  host.foo # => 'bar'
    def template_compatibility_properties(*property_symbols)
      @compatibility_properties = property_symbols
    end

    # Specify what should happen with the facet when the host object is deleted.
    # [+:destroy+] The facet object will be deleted by calling the destroy record.
    # [+:delete+] The facet will be deleted directly from the database without calling their destroy method.
    def set_dependent_action(value)
      @dependent = value
    end

    def load_api_controller
      @api_controller.to_s.constantize
    end
  end
end
