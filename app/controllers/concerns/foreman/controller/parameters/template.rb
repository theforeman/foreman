module Foreman::Controller::Parameters::Template
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::TemplateInput

  class_methods do
    def add_template_params_filter(filter)
      filter.permit :audit_comment,
        :default,
        :locked,
        :name,
        :description,
        :snippet,
        :template,
        :template_kind, :template_kind_id, :template_kind_name,
        :vendor,
        :template_inputs_attributes => [template_input_params_filter]
    end
  end
end
