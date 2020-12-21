module InputType
  class Base
    class Resolver
      attr_reader :input, :scope

      def initialize(input, scope)
        @input = input
        @scope = scope
      end

      def preview
        ready? ? resolved_value : preview_value
      end

      def value
        ready? ? resolved_value : raise(TemplateInput::ValueNotReady, "Input '#{@input.name}' is not ready for rendering")
      end

      def preview_value
        "$#{@input.input_type.upcase}_INPUT[#{@input.name}]"
      end

      # should be defined in descendants
      def ready?
        raise NotImplementedError
      end

      # should be defined in descendants
      def resolved_value
        raise NotImplementedError
      end
    end

    # ----- OWN METHODS ----

    def self.input_type_name
      @input_type_name ||= name.split('::').last.sub('Input', '').underscore
    end

    def self.humanized_name
      input_type_name.humanize
    end

    def self.available_for_template_class?(klass)
      klass.acceptable_template_input_types.include?(input_type_name.to_sym)
    end

    def self.attributes(*attrs)
      @attributes ||= []
      @attributes |= attrs
    end

    def self.api_params_for_input_group(context)
      attributes.each do |attr|
        context.param attr, String, required: false,
                                    desc: format(N_('%{input_type_attr_name}, used when input type is %{input_type}'), input_type_attr_name: attr.to_s.humanize, input_type: humanized_name)
      end
    end

    def validate(_input)
      # NO VALIDATIONS BY DEFAULT
    end

    def attributes_definition
      self.class.attributes
    end

    def name
      self.class.input_type_name
    end

    def resolver_class
      "#{self.class.name}::Resolver".safe_constantize
    end

    def resolver(input, scope)
      resolver_class.new(input, scope)
    end

    def additional_to_export(input, include_blank = true)
      attributes_definition.inject({}) do |hash, attribute|
        value = input.export_attr(attribute, include_blank)

        # Rails considers false blank, but if a boolean value is explicitly set false, we want to ensure we export it.
        if include_blank || value.present? || value == false
          hash.update(attribute => value)
        else
          hash
        end
      end.stringify_keys
    end

    def render_input_definition(view_context, f, template)
      res = ''.html_safe
      attributes_definition.each do |attr|
        res << view_context.text_f(f, attr, class: "#{name}_input_type", required: true, disabled: template.locked?)
      end
      res
    end
  end
end
