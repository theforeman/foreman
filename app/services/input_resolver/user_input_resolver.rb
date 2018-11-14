module InputResolver
  class UserInputResolver < Base
    def value
      raise(TemplateInput::UnsatisfiedRequiredInput, _("Value for required input '%s' was not specified") % @input.name) if required_value_needed?
      super
    end

    def ready?
      @scope.template_input_values.key?(@input.name)
    end

    def resolved_value
      input_value
    end

    def preview_value
      @input.template.is_a?(ReportTemplate) ? "" : super
    end

    private

    def required_value_needed?
      @input.required? && input_value.blank?
    end

    def input_value
      return unless @scope.template_input_values.key?(@input.name)
      @scope.template_input_values[@input.name]
    end
  end
end
