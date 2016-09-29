module Api
  module CompatibilityChecker
    extend ActiveSupport::Concern

    # removes unsupported "nested" flag from "host_parameters_attributes" (both Array and Hash formats supported)
    def check_create_host_nested
      params[:host] && params[:host][:host_parameters_attributes] && params[:host][:host_parameters_attributes].each do |attribute|
        attribute = attribute[1] if attribute.is_a? Array
        Foreman::Deprecation.api_deprecation_warning("Field host_parameters_attributes.nested ignored") unless attribute.delete(:nested).nil?
      end
    end
  end
end
