module Api
  module V1
    class ComputeResourcesController < V1::BaseController
      before_filter :find_resource, :only => [:show, :update, :destroy]

      api :GET, "/compute_resources/", "List all compute resources."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @compute_resources = ComputeResource.
          authorized(:view_compute_resources).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/compute_resources/:id/", "Show an compute resource."
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/compute_resources/", "Create a compute resource."
      param :compute_resource, Hash, :required => true do
        param :name, String, :required => true
        param :provider, String, :desc => "Providers include #{ComputeResource.providers.join(', ')}"
        param :url, String, :desc => "URL for Libvirt, oVirt, and OpenStack"
        param :description, String
        param :user, String, :desc => "Username for oVirt, EC2, VMware, OpenStack. Access Key for EC2."
        param :password, String, :desc => "Password for oVirt, EC2, VMware, OpenStack. Secret key for EC2"
        param :uuid, String, :desc => "for oVirt, VMware Datacenter"
        param :region, String, :desc => "for EC2 only"
        param :tenant, String, :desc => "for OpenStack only"
        param :server, String, :desc => "for VMware"
        param :set_console_password, :bool, :desc => N_("for Libvirt and VMware only")
      end

      def create
        @compute_resource = ComputeResource.new_provider(foreman_params)
        process_response @compute_resource.save
      end

      api :PUT, "/compute_resources/:id/", "Update a compute resource."
      param :id, String, :required => true
      param :compute_resource, Hash, :required => true do
        param :name, String
        param :provider, String, :desc => "Providers include #{ComputeResource.providers.join(', ')}"
        param :url, String, :desc => "URL for Libvirt, oVirt, and OpenStack"
        param :description, String
        param :user, String, :desc => "Username for oVirt, EC2, VMware, OpenStack. Access Key for EC2."
        param :password, String, :desc => "Password for oVirt, EC2, VMware, OpenStack. Secret key for EC2"
        param :uuid, String, :desc => "for oVirt, VMware Datacenter"
        param :region, String, :desc => "for EC2 only"
        param :tenant, String, :desc => "for OpenStack only"
        param :server, String, :desc => "for VMware"
      end

      def update
        process_response @compute_resource.update_attributes(foreman_params)
      end

      api :DELETE, "/compute_resources/:id/", "Delete a compute resource."
      param :id, :identifier, :required => true

      def destroy
        process_response @compute_resource.destroy
      end
    end
  end
end
