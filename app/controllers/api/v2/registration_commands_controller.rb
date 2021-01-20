module Api
  module V2
    class RegistrationCommandsController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::RegistrationCommands

      api :POST, "/registration_commands", N_("Generate global registration command")
      param :registration_command, Hash, required: false, action_aware: true do
        param :organization_id, :number, desc: N_("ID of the Organization to register the host in")
        param :location_id, :number, desc: N_("ID of the Location to register the host in")
        param :hostgroup_id, :number, desc: N_("ID of the Host group to register the host in")
        param :operatingsystem_id, :number, desc: N_("ID of the Operating System to register the host in")
        param :smart_proxy_id, :number, desc: N_("ID of the Smart Proxy")
        param :setup_insights, :bool, desc: N_("Set 'host_registration_insights' parameter for the host. If it is set to true, insights client will be installed and registered on Red Hat family operating systems")
        param :setup_remote_execution, :bool, desc: N_("Set 'host_registration_remote_execution' parameter for the host. If it is set to true, SSH keys will be installed on the host")
        param :jwt_expiration, :number, desc: N_("Expiration of the authorization token (in hours)")
        param :insecure, :bool, desc: N_("Enable insecure argument for the initial curl")
      end
      def create
        render json: { registration_command: command }
      end

      private

      def ignored_query_args
        ['jwt_expiration', 'smart_proxy_id', 'insecure']
      end

      def registration_params
        params[:registration_command]
      end
    end
  end
end
