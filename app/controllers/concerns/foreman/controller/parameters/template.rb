module Foreman::Controller::Parameters::Template
  extend ActiveSupport::Concern

  class_methods do
    def add_template_params_filter(filter)
      filter.permit :audit_comment,
        :default,
        :locked,
        :name,
        :snippet,
        :preview_enabled,
        :template,
        :template_kind, :template_kind_id, :template_kind_name,
        :vendor
    end
  end
end
