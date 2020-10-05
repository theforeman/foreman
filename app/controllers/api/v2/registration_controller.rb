module Api
  module V2
    class RegistrationController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::Registration
      include Foreman::Controller::Parameters::Registration

      rescue_from ActiveRecord::RecordNotFound do |error|
        logger.info "#{error.message} (#{error.class})"
        not_found(error.message)
      end

      rescue_from ActiveRecord::RecordInvalid do |error|
        render_error(error.message, status: :unprocessable_entity)
      end

      api :GET, '/register', N_('Render Global registration template')
      param :organization_id, :number, desc: N_("ID of the Organization to register the host in.")
      param :location_id, :number, desc: N_("ID of the Location to register the host in.")
      param :hostgroup_id, :number, desc: N_("ID of the Host group to register the host in.")
      param :operatingsystem_id, :number, desc: N_("ID of the Operating System to register the host in.")
      def global
        find_global_registration

        unless @provisioning_template
          not_found _('Global Registration Template with name %s defined via default_global_registration_item Setting not found, please configure the existing template name first') % Setting[:default_global_registration_item]
          return
        end

        render plain: @provisioning_template.render(variables: @global_registration_vars).html_safe
      end

      api :POST, "/register", N_("Find or create a host and render the Host registration template")
      param :name, String, required: true
      param :location_id, :number, required: true
      param :organization_id, :number, required: true
      param :ip, String, desc: N_("not required if using a subnet with DHCP proxy")
      param :mac, String, desc: N_("required for managed host that is bare metal, not required if it's a virtual machine")
      param :domain_id, :number, desc: N_("required if host is managed and value is not inherited from host group")
      param :operatingsystem_id, :number, desc: N_("required if host is managed and value is not inherited from host group")
      param :subnet_id, :number, desc: N_("required if host is managed and value is not inherited from host group")
      param :model_id, :number
      param :hostgroup_id, :number
      param :host_parameters_attributes, Array, desc: N_("Host's parameters (array or indexed hash)") do
        param :name, String, desc: N_("Name of the parameter"), required: true
        param :value, String, desc: N_("Parameter value"), required: true
        param :parameter_type, Parameter::KEY_TYPES, desc: N_("Type of value")
        param :hidden_value, :bool
      end
      param :build, :bool
      param :enabled, :bool, desc: N_("Include this host within Foreman reporting")
      param :managed, :bool, desc: N_("True/False flag whether a host is managed or unmanaged. Note: this value also determines whether several parameters are required or not")
      param :comment, String, desc: N_("Additional information about this host")
      param :interfaces_attributes, Array, desc: N_("Host's network interfaces.") do
        param_group :interface_attributes, ::Api::V2::InterfacesController
      end
      Facets.registered_facets.values.each do |facet_config|
        next unless facet_config.host_configuration.api_param_group && facet_config.host_configuration.api_controller
        param "#{facet_config.name}_attributes".to_sym, Hash, desc: facet_config.api_param_group_description || (N_("Parameters for host's %s facet") % facet_config.name) do
          facet_config.host_configuration.load_api_controller
          param_group facet_config.host_configuration.api_param_group, facet_config.host_configuration.api_controller
        end
      end
      def host
        begin
          ActiveRecord::Base.transaction do
            find_host
            prepare_host
            @template = @host.registration_template
            raise ActiveRecord::Rollback if @template.nil?
          end
        rescue ::Foreman::Exception => e
          render_error(e.message, status: :unprocessable_entity)
          return
        end

        unless @template
          not_found N_("Unable to find registration template for host %{host} running %{os}, associate the registration template for this OS first") % { host: @host.name, os: @host.operatingsystem }
          return
        end

        @host.setBuild
        safe_render(@template)
      end

      private

      def find_host
        @host = Host.find_or_initialize_by(name: host_params('host')['name'])
      end

      def prepare_host
        hostgroup_id = host_params('host')['hostgroup_id']

        @host.assign_attributes(host_params('host'))
        # Hardcoded params so they can't be overridden
        @host.hostgroup = Hostgroup.authorized(:view_hostgroups).find(hostgroup_id) if hostgroup_id
        @host.owner = User.current

        @host.save!
      end
    end
  end
end
