module Foreman::Controller::TemplateImport
  extend ActiveSupport::Concern
  def import_attrs_for(resource_name)
    options = params.permit(:options => {}).try(:[], :options).try(:to_h) || {}
    options[:organization_params] = organization_params.to_h
    options[:location_params] = location_params.to_h
    template_params = params.require(resource_name).permit(:name, :template)
    [template_params[:name], template_params[:template], options]
  end
end
