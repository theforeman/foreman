module Api
  module V2
    class OverrideValuesController < V2::BaseController
      include Api::V2::ExtractedPuppetController

      api :GET, "/smart_class_parameters/:smart_class_parameter_id/override_values", N_("List of override values for a specific smart class parameter")
      def index
      end

      api :GET, "/smart_class_parameters/:smart_class_parameter_id/override_values/:id", N_("Show an override value for a specific smart class parameter")
      def show
      end

      api :POST, "/smart_class_parameters/:smart_class_parameter_id/override_values", N_("Create an override value for a specific smart class parameter")
      def create
      end

      api :PUT, "/smart_class_parameters/:smart_class_parameter_id/override_values/:id", N_("Update an override value for a specific smart class parameter")
      def update
      end

      api :DELETE, "/smart_class_parameters/:smart_class_parameter_id/override_values/:id", N_("Delete an override value for a specific smart class parameter")
      def destroy
      end

      def resource_human_name
        _('Override Value')
      end
    end
  end
end
