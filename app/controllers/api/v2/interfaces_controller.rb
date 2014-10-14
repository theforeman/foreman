module Api
  module V2
    class InterfacesController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_required_nested_object, :only => [:index, :show, :create, :destroy]
      before_filter :find_resource, :only => [:show, :update, :destroy]

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
          param :mac, String, :required => true, :desc => N_("MAC address of interface")
          param :ip, String, :required => true, :desc => N_("IP address of interface")
          param :type, String, :required => true, :desc => N_("Interface type, e.g: Nic::BMC")
          param :name, String, :required => true, :desc => N_("Interface name")
          param :subnet_id, Fixnum, :desc => N_("Foreman subnet ID of interface")
          param :domain_id, Fixnum, :desc => N_("Foreman domain ID of interface")
          param :username, String
          param :password, String
          param :provider, String, :desc => N_("Interface provider, e.g. IPMI")
          param :managed, :bool, :desc => N_("Should this interface be managed via DHCP and DNS smart proxy and should it be configured during provisioning?")
          param :virtual, :bool, :desc => N_("Alias or VLAN device")
          param :identifier, String, :desc => N_("Device identifier, e.g. eth0 or eth1.1")
          param :tag, String, :desc => N_("VLAN tag, this attribute has precedence over the subnet VLAN ID")
          param :attached_to, String, :desc => N_("Identifier of the interface to which this interface belongs, e.g. eth1")
          param :mode, String, :desc => N_("Bond mode of the interface, e.g. balance-rr")
          param :attached_devices, Array, :desc => N_("Identifiers of slave interfaces, e.g. `['eth1', 'eth2']`")
          param :bond_options, String, :desc => N_("Space separated options, e.g. miimon=100")
        end
      end

      api :POST, '/hosts/:host_id/interfaces', N_("Create an interface on a host")
      param :host_id, String, :required => true, :desc => N_("ID or name of host")
      param_group :interface, :as => :create

      def create
        interface = @nested_obj.interfaces.new(params[:interface], :without_protection => true)
        if interface.save
          render :json => interface, :status => :created
        else
          render :json => { :errors => interface.errors.full_messages }, :status => :unprocessable_entity
        end
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
    end
  end
end
