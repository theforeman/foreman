module Foreman::Controller::Parameters::ReportTemplate
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::Taxonomix
  include Foreman::Controller::Parameters::Template

  class_methods do
    def report_template_params_filter
      Foreman::ParameterFilter.new(::ReportTemplate).tap do |filter|
        add_taxonomix_params_filter(filter)
        add_template_params_filter(filter)
      end
    end
  end

  def report_template_params
    self.class.report_template_params_filter.filter_params(params, parameter_filter_context)
  end

  def organization_params
    self.class.organization_params_filter(::ReportTemplate).filter_params(params, parameter_filter_context)
  end

  def location_params
    self.class.location_params_filter(::ReportTemplate).filter_params(params, parameter_filter_context)
  end
end
