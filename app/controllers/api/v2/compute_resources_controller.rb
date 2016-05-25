module Api
  module V2
    class ComputeResourcesController < V2::BaseController
      include Api::Version2
      include Api::TaxonomyScope
      include Foreman::Controller::Parameters::ComputeResource

      wrap_parameters ComputeResource, :include => compute_resource_params_filter.accessible_attributes(parameter_filter_context)

      before_action :find_resource, :only => [:show, :update, :destroy, :available_images, :associate,
                                              :available_clusters, :available_flavors, :available_folders,
                                              :available_networks, :available_resource_pools, :available_security_groups, :available_storage_domains,
                                              :available_zones, :available_storage_pods]

      api :GET, "/compute_resources/", N_("List all compute resources")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @compute_resources = resource_scope_for_index
      end

      api :GET, "/compute_resources/:id/", N_("Show a compute resource")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :compute_resource do
        param :compute_resource, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :provider, String, :desc => N_("Providers include %{providers}") # values are defined in apipie initializer
          param :url, String, :desc => N_("URL for Libvirt, oVirt, and OpenStack")
          param :description, String
          param :user, String, :desc => N_("Username for oVirt, EC2, VMware, OpenStack. Access Key for EC2.")
          param :password, String, :desc => N_("Password for oVirt, EC2, VMware, OpenStack. Secret key for EC2")
          param :uuid, String, :desc => N_("for oVirt, VMware Datacenter")
          param :region, String, :desc => N_("for EC2 only")
          param :tenant, String, :desc => N_("for OpenStack only")
          param :server, String, :desc => N_("for VMware")
          param :set_console_password, :bool, :desc => N_("for Libvirt and VMware only")
          param :display_type, %w(VNC SPICE), :desc => N_('for Libvirt only')
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, "/compute_resources/", N_("Create a compute resource")
      param_group :compute_resource, :as => :create

      def create
        @compute_resource = ComputeResource.new_provider(compute_resource_params)
        process_response @compute_resource.save
      end

      api :PUT, "/compute_resources/:id/", N_("Update a compute resource")
      param :id, String, :required => true
      param_group :compute_resource

      def update
        process_response @compute_resource.update_attributes(compute_resource_params)
      end

      api :DELETE, "/compute_resources/:id/", N_("Delete a compute resource")
      param :id, :identifier, :required => true

      def destroy
        process_response @compute_resource.destroy
      end

      api :GET, "/compute_resources/:id/available_images/", N_("List available images for a compute resource")
      param :id, :identifier, :required => true
      def available_images
        @available_images = @compute_resource.available_images
      end

      api :GET, "/compute_resources/:id/available_clusters", N_("List available clusters for a compute resource")
      param :id, :identifier, :required => true
      def available_clusters
        @available_clusters = @compute_resource.available_clusters
        render :available_clusters, :layout => 'api/v2/layouts/index_layout'
      end

      api :GET, "/compute_resources/:id/available_flavors", N_("List available flavors for a compute resource")
      param :id, :identifier, :required => true
      def available_flavors
        @available_flavors = @compute_resource.available_flavors
        render :available_flavors, :layout => 'api/v2/layouts/index_layout'
      end

      api :GET, "/compute_resources/:id/available_folders", N_("List available folders for a compute resource")
      param :id, :identifier, :required => true
      def available_folders
        @available_folders = @compute_resource.available_folders
        render :available_folders, :layout => 'api/v2/layouts/index_layout'
      end

      api :GET, "/compute_resources/:id/available_zones", N_("List available zone for a compute resource")
      param :id, :identifier, :required => true
      def available_zones
        @available_zones = @compute_resource.available_zones
        render :available_zones, :layout => 'api/v2/layouts/index_layout'
      end

      api :GET, "/compute_resources/:id/available_networks", N_("List available networks for a compute resource")
      api :GET, "/compute_resources/:id/available_clusters/:cluster_id/available_networks", N_("List available networks for a compute resource cluster")
      param :id, :identifier, :required => true
      param :cluster_id, String
      def available_networks
        @available_networks = @compute_resource.available_networks(params[:cluster_id])
        render :available_networks, :layout => 'api/v2/layouts/index_layout'
      end

      api :GET, "/compute_resources/:id/available_clusters/:cluster_id/available_resource_pools", N_("List resource pools for a compute resource cluster")
      param :id, :identifier, :required => true
      param :cluster_id, String, :required => true
      def available_resource_pools
        @available_resource_pools = @compute_resource.available_resource_pools({ :cluster_id => params[:cluster_id] })
        render :available_resource_pools, :layout => 'api/v2/layouts/index_layout'
      end

      api :GET, "/compute_resources/:id/available_storage_domains", N_("List storage domains for a compute resource")
      api :GET, "/compute_resources/:id/available_storage_domains/:storage_domain", N_("List attributes for a given storage domain")
      api :GET, "/compute_resources/:id/available_clusters/:cluster_id/available_storage_domains", N_("List available storage domains for a compute resource cluster")
      param :id, :identifier, :required => true
      param :storage_domain, String
      param :cluster_id, String
      def available_storage_domains
        @available_storage_domains = @compute_resource.available_storage_domains(params[:storage_domain], params[:cluster_id])
        render :available_storage_domains, :layout => 'api/v2/layouts/index_layout'
      end

      api :GET, "/compute_resources/:id/available_storage_pods", N_("List storage pods for a compute resource")
      api :GET, "/compute_resources/:id/available_storage_pods/:storage_pod", N_("List attributes for a given storage pod")
      param :id, :identifier, :required => true
      param :storage_pod, String
      def available_storage_pods
        @available_storage_pods = @compute_resource.available_storage_pods(params[:storage_pod])
        render :available_storage_pods, :layout => 'api/v2/layouts/index_layout'
      end

      api :GET, "/compute_resources/:id/available_security_groups", N_("List available security groups for a compute resource")
      param :id, :identifier, :required => true
      def available_security_groups
        @available_security_groups = @compute_resource.available_security_groups
        render :available_security_groups, :layout => 'api/v2/layouts/index_layout'
      end

      api :PUT, "/compute_resources/:id/associate/", N_("Associate VMs to Hosts")
      param :id, :identifier, :required => true
      def associate
        @hosts = []
        if @compute_resource.respond_to?(:associated_host)
          @compute_resource.vms(:eager_loading => true).each do |vm|
            if Host.for_vm(@compute_resource, vm).empty?
              host = @compute_resource.associated_host(vm)
              if host.present?
                host.associate!(@compute_resource, vm)
                @hosts << host
              end
            end
          end
        end
        render 'api/v2/hosts/index', :layout => 'api/v2/layouts/index_layout'
      end

      private

      def action_permission
        case params[:action]
          when 'available_images', 'available_clusters', 'available_flavors', 'available_folders', 'available_networks', 'available_resource_pools', 'available_security_groups', 'available_storage_domains', 'available_zones', 'associate', 'available_storage_pods'
            :view
          else
            super
        end
      end
    end
  end
end
