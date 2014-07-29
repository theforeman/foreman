module Api
  module V2
    class InterfacesController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => [:show, :update, :destroy]
      before_filter :find_required_nested_object, :only => [:index, :show, :create]

      api :GET, '/hosts/:host_id/interfaces', N_("List all interfaces for host")
      param :host_id, String, :required => true, :desc => N_("ID or name of host")

      def index
        @interfaces = @nested_obj.interfaces.paginate(paginate_options)
        @total = @nested_obj.interfaces.count
      end

      api :GET, '/hosts/:host_id/interfaces/:id', N_("Show an interface for host")
      param :host_id, String, :required => true, :desc => N_("ID or name of host")
      param :id, String, :required => true, :desc => N_("ID or name of interface")

      def show
      end

      def_param_group :interface do
        param :interface, Hash, :action_aware => true, :desc => N_("interface information") do
          param :mac, String, :required => true, :desc => N_("MAC address of interface")
          param :ip, String, :required => true, :desc => N_("IP address of interface")
          param :type, String, :required => true, :desc => N_("Interface type, i.e: Nic::BMC")
          param :name, String, :required => true, :desc => N_("Interface name")
          param :subnet_id, Fixnum, :desc => N_("Foreman subnet ID of interface")
          param :domain_id, Fixnum, :desc => N_("Foreman domain ID of interface")
          param :username, String
          param :password, String
          param :provider, String, :desc => N_("Interface provider, i.e. IPMI")
        end
      end

      api :POST, '/hosts/:host_id/interfaces', N_("Create an interface on a host")
      param :host_id, String, :required => true, :desc => N_("ID or name of host")
      param_group :interface, :as => :create

      def create
        interface = @nested_obj.interfaces.new(params[:interface], :without_protection => true)
        if interface.save
          render :json => interface, :status => 201
        else
          render :json => { :errors => interface.errors.full_messages }, :status => 422
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
      param :id, String, :required => true, :desc => N_("ID of interface")

      def destroy
        process_response @interface.destroy
      end

      private

      def allowed_nested_id
        %w(host_id)
      end

      def resource_class
        Nic::Base
      end
    end
  end
end
