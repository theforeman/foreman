module Api
  module V2
    class SmartClassParametersController < V2::BaseController
      include Api::V2::ExtractedPuppetController

      api :GET, "/smart_class_parameters", N_("List all smart class parameters")
      api :GET, "/hosts/:host_id/smart_class_parameters", N_("List of smart class parameters for a specific host")
      api :GET, "/hostgroups/:hostgroup_id/smart_class_parameters", N_("List of smart class parameters for a specific host group")
      api :GET, "/puppetclasses/:puppetclass_id/smart_class_parameters", N_("List of smart class parameters for a specific Puppet class")
      api :GET, "/environments/:environment_id/smart_class_parameters", N_("List of smart class parameters for a specific environment")
      api :GET, "/environments/:environment_id/puppetclasses/:puppetclass_id/smart_class_parameters", N_("List of smart class parameters for a specific environment/Puppet class combination")
      def index
      end

      api :GET, "/smart_class_parameters/:id/", N_("Show a smart class parameter")

      def show
      end

      api :PUT, "/smart_class_parameters/:id", N_("Update a smart class parameter")
      def update
      end

      def resource_human_name
        _('Smart Class Parameter')
      end
    end
  end
end
