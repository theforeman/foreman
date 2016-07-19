module Api
  module CompatibilityChecker
    extend ActiveSupport::Concern

    # removes unsupported "nested" flag from "host_parameters_attributes" (both Array and Hash formats supported)
    def check_create_host_nested
      if params[:host] && (attrs = params[:host][:host_parameters_attributes])
        attrs = attrs.values unless attrs.is_a?(Array)
        attrs.each do |attribute|
          Foreman::Deprecation.api_deprecation_warning("Field host_parameters_attributes.nested ignored") unless attribute.delete(:nested).nil?
        end
      end
    end
  end
end
