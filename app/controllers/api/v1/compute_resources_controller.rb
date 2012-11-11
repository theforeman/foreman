module Api
  module V1
    class ComputeResourcesController < V1::BaseController
      before_filter :find_resource, :only => [:show, :update, :destroy]

      api :GET, "/compute_resources/", "List all compute resources."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        @compute_resources = ComputeResource.my_compute_resources.search_for(params[:search], :order => params[:order])

      end

      api :GET, "/compute_resources/:id/", "Show an compute resource."
      param :id, :identifier, :required => true
      def show
      end

      api :POST, "/compute_resources/", "Create a compute resource."
      param :compute_resource, Hash, :required => true do
        param :name, String, :required => true
        param :provider, String, :required => true, :desc => "Providers include #{ComputeResource::PROVIDERS.join(', ')}"
        param :url, String, :desc => "URL for Libvirt, Ovirt, and Openstack"
        param :description, String
        param :user, String, :desc => "Username for Ovirt, EC2, Vmware, Openstack. Access Key for EC2."
        param :password, String, :desc => "Password for Ovirt, EC2, Vmware, Openstack. Secret key for EC2"
        param :uuid, String, :desc => "for Ovirt, Vmware Datacenter"
        param :region, String, :desc => "for EC2 only"
        param :tenant, String, :desc => "for Openstack only"
        param :server, String, :desc => "for Vmware"
      end
      def create
        #debugger
          if params[:compute_resource].present? && params[:compute_resource][:provider].present?
            @compute_resource = ComputeResource.new_provider params[:compute_resource]
            # Add the new compute resource to the user's filters
            @compute_resource.users << User.current
            process_response @compute_resource.save
          else
            @compute_resource = ComputeResource.new(params[:compute_resource])
            process_response @compute_resource.save
          end
      end
      api :PUT, "/compute_resources/:id/", "Update a compute resource."
      param :id, String, :required => true
      param :compute_resource, Hash, :required => true do
        param :name, String, :required => true
        param :provider, String, :required => true, :desc => "Providers include #{ComputeResource::PROVIDERS.join(', ')}"
        param :url, String, :required => true, :desc => "URL for Libvirt, Ovirt, and Openstack"
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

      api :DELETE, "/compute_resources/:id/", "Delete a compute resource."
      param :id, String, :required => true
      def destroy
        process_response @compute_resource.destroy
      end

    end
  end
end
