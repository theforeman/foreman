module Api
  module V2
    class InterfacesController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => [:show, :update, :destroy]
      before_filter :find_required_nested_object, :only => [:index, :show, :create]

      api :GET, '/hosts/:host_id/interfaces', 'List all interfaces for host'
      param :host_id, String, :required => true, :desc => 'id or name of host'

      def index
        @interfaces = @nested_obj.interfaces.paginate(paginate_options)
      end

      api :GET, '/hosts/:host_id/interfaces/:id', 'Show an interface for host'
      param :host_id, String, :required => true, :desc => 'id or name of nested host'
      param :id, String, :required => true, :desc => 'id or name of interface'

      def show
      end

      api :POST, '/hosts/:host_id/interfaces', 'Create an interface linked to a host'
      param :host_id, String, :required => true, :desc => 'id or name of host'
      param :interface, Hash, :required => true, :desc => 'interface information' do
        param :mac, String, :required => true, :desc => 'MAC address of interface'
        param :ip, String, :required => true, :desc => 'IP address of interface'
        param :type, String, :required => true, :desc => 'Interface type, i.e: Nic::BMC'
        param :name, String, :required => true, :desc => 'Interface name'
        param :subnet_id, Fixnum, :desc => 'Foreman subnet id of interface'
        param :domain_id, Fixnum, :desc => 'Foreman domain id of interface'
        param :username, String
        param :password, String
        param :provider, String, :desc => 'Interface provider, i.e: IPMI'
      end

      def create
        interface = @nested_obj.interfaces.new(params[:interface], :without_protection => true)
        if interface.save
          render :json => interface, :status => 201
        else
          render :json => { :errors => interface.errors.full_messages }, :status => 422
        end
      end

      api :PUT, "/hosts/:host_id/interfaces/:id", "Update host interface"
      param :host_id, String, :required => true, :desc => 'id or name of host'
      param :interface, Hash, :required => true, :desc => 'interface information' do
        param :mac, String, :desc => 'MAC address of interface'
        param :ip, String, :desc => 'IP address of interface'
        param :type, String, :desc => 'Interface type, i.e: Nic::BMC'
        param :name, String, :desc => 'Interface name'
        param :subnet_id, Fixnum, :desc => 'Foreman subnet id of interface'
        param :domain_id, Fixnum, :desc => 'Foreman domain id of interface'
        param :username, String
        param :password, String
        param :provider, String, :desc => 'Interface provider, i.e: IPMI'
      end

      def update
        process_response @interface.update_attributes(params[:interface], :without_protection => true)
      end

      api :DELETE, "/hosts/:host_id/interfaces/:id", "Delete a host interface"
      param :id, String, :required => true, :desc => "id of interface"

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
