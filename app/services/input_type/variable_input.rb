module InputType
  class VariableInput < Base
    class Resolver < Base::Resolver
      def ready?
        @scope&.host&.params&.key?(@input.variable_name)
      end

      def resolved_value
        @scope.host.params[@input.variable_name]
      end
    end

    def self.humanized_name
      _('Variable')
    end

    attributes :variable_name

    def validate(input)
      input.errors.add(:variable_name, :blank) if input.variable_name.blank?
    end
  end
end
