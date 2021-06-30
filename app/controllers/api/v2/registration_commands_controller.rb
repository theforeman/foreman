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
        param :packages, String, desc: N_("Packages to install on the host when registered. Can be set by `host_packages` parameter. Example: `pkg1 pkg2`")
        param :update_packages, :bool, desc: N_("Update all packages on the host")
        param :repo, String, desc: N_("Repository URL / details, for example for Debian OS family: 'deb http://deb.example.com/ buster 1.0', for Red Hat OS family: 'http://yum.theforeman.org/client/latest/el8/x86_64/'")
        param :repo_gpg_key_url, String, desc: N_("URL of the GPG key for the repository")
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
