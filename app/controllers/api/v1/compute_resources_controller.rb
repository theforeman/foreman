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
        @compute_resources = ComputeResource.my_compute_resources.search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/compute_resources/:id/", "Show an compute resource."
      param :id, :identifier, :required => true

      def show
      end

      api :PUT, "/compute_resources/:id/", "Update a compute resource."
      param :id, String, :required => true
      param :compute_resource, Hash, :required => true do
        param :name, String
        param :provider, String, :desc => "Providers include #{ComputeResource::PROVIDERS.join(', ')}"
        param :url, String, :desc => "URL for Libvirt, Ovirt, and Openstack"
        param :description, String
        param :user, String, :desc => "Username for Ovirt, EC2, Vmware, Openstack. Access Key for EC2."
        param :password, String, :desc => "Password for Ovirt, EC2, Vmware, Openstack. Secret key for EC2"
        param :uuid, String, :desc => "for Ovirt, Vmware Datacenter"
        param :region, String, :desc => "for EC2 only"
        param :tenant, String, :desc => "for Openstack only"
        param :server, String, :desc => "for Vmware"
      end

      def update
        process_response @compute_resource.update_attributes(params[:compute_resource])
      end

    end
  end
end
