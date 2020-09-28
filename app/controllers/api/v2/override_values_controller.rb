module Api
  module V2
    class OverrideValuesController < V2::BaseController
      include Api::Version2
      prepend_before_action :fail_and_inform_about_plugin

      resource_description do
        desc 'This resource has been deprecated, to continue using it please install Foreman Puppet Enc plugin and use its API enpoints.'
        deprecated true
      end

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

      private

      def fail_and_inform_about_plugin
        render json: { message: _('To access SmartClassParameters API you need to install Foreman Puppet Enc plugin') }, status: :not_implemented
      end
    end
  end
end
