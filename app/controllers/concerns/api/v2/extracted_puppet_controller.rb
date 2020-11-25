module Api
  module V2
    module ExtractedPuppetController
      extend ActiveSupport::Concern

      included do
        prepend_before_action :fail_and_inform_about_plugin

        resource_description do
          desc 'This resource has been removed. To continue using it please install the Foreman Puppet plugin and use its API endpoints.'
          deprecated true
        end
      end

      def resource_human_name
        resource_name.classify
      end

      def fail_and_inform_about_plugin
        render json: { message: _('To access %s API, you need to install the Foreman Puppet plugin') % resource_human_name }, status: :not_implemented
      end
    end
  end
end
