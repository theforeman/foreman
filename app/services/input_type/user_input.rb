module InputType
  class UserInput < Base
    class Resolver < Base::Resolver
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

    def self.humanized_name
      _('User input')
    end

    def render_input_definition(view_context, f, template)
      res = ''.html_safe
      res << view_context.checkbox_f(f, :advanced, disabled: template.locked?)
      res << view_context.checkbox_f(f, :hidden_value, disabled: template.locked?,
                                                       label_help: _('Should the value be hidden from users? '\
                                                                     'Useful for sensitive input values such as passwords. '\
                                                                     'Only applicable to Plain value types.'),
                                                       wrapper_class: "form-group input-hidden-value-#{f.index || f.object_id}#{' hide' if f.object.value_type != 'plain'}")
      res << view_context.textarea_f(f, :options, rows: 3,
                                                  disabled: template.locked?,
                                                  class: 'user_input_type',
                                                  help_inline: _('A list of options the user can select from. '\
                                                                 'If not provided, the user will be given a free-form field'),
                                                  wrapper_class: "form-group input-options-#{f.index || f.object.id}#{' hide' if f.object.value_type != 'plain'}")
      res << view_context.text_f(f, :default, disabled: template.locked?)
      res
    end
  end
end
