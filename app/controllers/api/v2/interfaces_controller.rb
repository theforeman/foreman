require_dependency File.join(Rails.root, "app/models/nic/base")

module Api
  module V2
    class InterfacesController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      ALLOWED_TYPE_NAMES = Nic::Base.allowed_types.map{ |t| t.humanized_name.downcase }
      LEGACY_TYPE_NAMES = Nic::Base.allowed_types.map{ |t| t.name }

      before_filter :find_required_nested_object, :only => [:index, :show, :create, :destroy]
      before_filter :find_resource, :only => [:show, :update, :destroy]
      before_filter :convert_type, :only => [:create, :update]

      api :GET, '/hosts/:host_id/interfaces', N_("List all interfaces for host")
      api :GET, '/domains/:domain_id/interfaces', N_('List all interfaces for domain')
      api :GET, '/subnets/:subnet_id/interfaces', N_('List all interfaces for subnet')
      param :host_id, String, :required => true, :desc => N_("ID or name of host")
      param :domain_id, String, :required => false, :desc => N_('ID or name of domain')
      param :subnet_id, String, :required => false, :desc => N_('ID or name of subnet')
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")

      def index
        @interfaces = resource_scope.paginate(paginate_options)
      end

      api :GET, '/hosts/:host_id/interfaces/:id', N_("Show an interface for host")
      param :host_id, String, :required => true, :desc => N_("ID or name of host")
      param :id, String, :required => true, :desc => N_("ID or name of interface")

      def show
      end

      def_param_group :interface do
        param :interface, Hash, :required => true, :action_aware => true, :desc => N_("interface information") do
          #common parameters
          param :mac, String, :required => true, :desc => N_("MAC address of interface")
          param :ip, String, :required => true, :desc => N_("IP address of interface")
          param :type, InterfacesController::ALLOWED_TYPE_NAMES, :required => true, :desc => N_("Interface type, e.g: bmc")
          param :name, String, :required => true, :desc => N_("Interface name")
          param :subnet_id, Fixnum, :desc => N_("Foreman subnet ID of interface")
          param :domain_id, Fixnum, :desc => N_("Foreman domain ID of interface")
          param :identifier, String, :desc => N_("Device identifier, e.g. eth0 or eth1.1")
          param :managed, :bool, :desc => N_("Should this interface be managed via DHCP and DNS smart proxy and should it be configured during provisioning?")
          #bmc specific parameters
          param :username, String, :desc => N_("Only for BMC interfaces.")
          param :password, String, :desc => N_("Only for BMC interfaces.")
          param :provider, Nic::BMC::PROVIDERS, :desc => N_("Interface provider, e.g. IPMI. Only for BMC interfaces.")
          #virtual device specific parameters
          param :virtual, :bool, :desc => N_("Alias or VLAN device")
          param :tag, String, :desc => N_("VLAN tag, this attribute has precedence over the subnet VLAN ID. Only for virtual interfaces.")
          param :attached_to, String, :desc => N_("Identifier of the interface to which this interface belongs, e.g. eth1. Only for virtual interfaces.")
          #bond specific parameters
          param :mode, Nic::Bond::MODES, :desc => N_("Bond mode of the interface, e.g. balance-rr. Only for bond interfaces.")
          param :attached_devices, Array, :desc => N_("Identifiers of slave interfaces, e.g. `['eth1', 'eth2']`. Only for bond interfaces.")
          param :bond_options, String, :desc => N_("Space separated options, e.g. miimon=100. Only for bond interfaces.")
        end
      end

      api :POST, '/hosts/:host_id/interfaces', N_("Create an interface on a host")
      param :host_id, String, :required => true, :desc => N_("ID or name of host")
      param_group :interface, :as => :create

      def create
        @interface = @nested_obj.interfaces.new(params[:interface], :without_protection => true)
        process_response @interface.save
      end

      api :PUT, "/hosts/:host_id/interfaces/:id", N_("Update a host's interface")
      param :host_id, String, :required => true, :desc => N_("ID or name of host")
      param :id, :identifier, :required => true, :desc => N_("ID of interface")
      param_group :interface

      def update
        process_response @interface.update_attributes(params[:interface], :without_protection => true)
      end

      api :DELETE, "/hosts/:host_id/interfaces/:id", N_("Delete a host's interface")
      param :host_id, String, :required => true, :desc => N_('ID or name of host')
      param :id, String, :required => true, :desc => N_("ID of interface")

      def destroy
        process_response @interface.destroy
      end

      private

      def allowed_nested_id
        %w(host_id domain_id subnet_id)
      end

      def resource_class
        Nic::Base
      end

      def convert_type
        type_sent = params[:interface][:type]

        if ALLOWED_TYPE_NAMES.include? type_sent
          # convert human readable name to the NIC's class name
          params[:interface][:type] = Nic::Base.type_by_name(type_sent).to_s
        elsif !LEGACY_TYPE_NAMES.include? type_sent
          # enable sending class names directly to keep backward compatibility
          render_error :custom_error,
            :status => :unprocessable_entity,
            :locals => {
              :message => _("Unknown interface type, must be one of [%s]") % ALLOWED_TYPE_NAMES.join(', ')
            }
        end
      end

    end
  end
end
