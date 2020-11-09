module Foreman
  class InputTypesRegistry
    def input_types
      @input_types ||= {}
    end

    def register(type_class)
      input_types[type_class.input_type_name] = type_class
    end

    def get(type_name)
      type_name = type_name.to_s
      raise "unknown input type '#{type_name}'" unless input_types.key?(type_name)
      input_types[type_name]
    end

    def types_for_template_class(klass)
      input_types.values.select { |type_class| type_class.available_for_template_class?(klass) }
    end
  end
end
