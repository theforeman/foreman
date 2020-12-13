module Api
  module V2
    class ComputeResourcesController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::Parameters::ComputeResource

      wrap_parameters ComputeResource, :include => compute_resource_params_filter.accessible_attributes(parameter_filter_context)

      before_action :find_resource, :only => [:show, :update, :destroy, :available_images, :associate,
                                              :available_virtual_machines, :available_clusters, :available_flavors, :available_folders,
                                              :available_networks, :available_resource_pools, :available_security_groups, :available_storage_domains,
                                              :available_zones, :available_storage_pods, :storage_domain, :storage_pod, :refresh_cache, :power_vm, :show_vm, :destroy_vm]

      api :GET, "/compute_resources/", N_("List all compute resources")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(ComputeResource)

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
          param :url, String, :desc => N_("URL for %{providers_requiring_url}")
          param :description, String
          param :user, String, :desc => N_("Username for oVirt, EC2, VMware, OpenStack. Access Key for EC2.")
          param :password, String, :desc => N_("Password for oVirt, EC2, VMware, OpenStack. Secret key for EC2")
          param :datacenter, String, :desc => N_("for oVirt, VMware Datacenter")
          param :ovirt_quota, String, :desc => N_("for oVirt only, ID or Name of quota to use")
          param :public_key, String, :desc => N_("for oVirt only")
          param :region, String, :desc => N_("for AzureRm eg. 'eastus' and for EC2 only. Use '%s' for EC2 GovCloud region") % Foreman::Model::EC2::GOV_CLOUD_REGION
          param :tenant, String, :desc => N_("for OpenStack and AzureRm only")
          param :domain, String, :desc => N_("for OpenStack (v3) only")
          param :project_domain_name, String, :desc => N_("for OpenStack (v3) only")
          param :project_domain_id, String, :desc => N_("for OpenStack (v3) only")
          param :server, String, :desc => N_("for VMware")
          param :set_console_password, :bool, :desc => N_("for Libvirt and VMware only")
          param :display_type, %w(VNC SPICE), :desc => N_('for Libvirt and oVirt only')
          param :keyboard_layout, ComputeResource::ALLOWED_KEYBOARD_LAYOUTS, :desc => N_('for oVirt only')
          param :caching_enabled, :bool, :desc => N_('enable caching, for VMware only')
          param :project, String, :desc => N_("Project id for GCE only")
          param :email, String, :desc => N_("Email for GCE only")
          param :key_path, String, :desc => N_("Certificate path for GCE only")
          param :zone, String, :desc => N_("for GCE only")
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      def change_datacenter_to_uuid(datacenter)
        if @compute_resource.respond_to?(:get_datacenter_uuid) && datacenter.present?
          @compute_resource.test_connection
          @compute_resource.get_datacenter_uuid(datacenter)
        end
      end

      api :POST, "/compute_resources/", N_("Create a compute resource")
      param_group :compute_resource, :as => :create

      def create
        begin
          if compute_resource_params["provider"].downcase == "ovirt" && !Foreman.is_uuid?(compute_resource_params[:datacenter])
            @compute_resource = ComputeResource.new_provider(compute_resource_params.except(:datacenter))
            params[:compute_resource][:datacenter] = change_datacenter_to_uuid(params[:compute_resource][:datacenter])
          end
          @compute_resource = ComputeResource.new_provider(compute_resource_params)
        rescue Foreman::Exception => e
          render_exception(e, :status => :unprocessable_entity)
          return
        end

        process_response @compute_resource.save
      end

      api :PUT, "/compute_resources/:id/", N_("Update a compute resource")
      param :id, String, :required => true
      param_group :compute_resource

      def update
        datacenter = change_datacenter_to_uuid(compute_resource_params[:datacenter])
        update_parameters = datacenter.present? ? compute_resource_params.merge(:datacenter => datacenter) : compute_resource_params
        process_response @compute_resource.update(update_parameters)
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
        @total = @available_clusters&.size
        render :available_clusters, :layout => 'api/v2/layouts/index_layout'
      end

      api :GET, "/compute_resources/:id/available_flavors", N_("List available flavors for a compute resource")
      param :id, :identifier, :required => true
      def available_flavors
        @available_flavors = @compute_resource.available_flavors
        @total = @available_flavors&.size
        render :available_flavors, :layout => 'api/v2/layouts/index_layout'
      end

      api :GET, "/compute_resources/:id/available_folders", N_("List available folders for a compute resource")
      param :id, :identifier, :required => true
      def available_folders
        @available_folders = @compute_resource.available_folders
        @total = @available_folders&.size
        render :available_folders, :layout => 'api/v2/layouts/index_layout'
      end

      api :GET, "/compute_resources/:id/available_zones", N_("List available zone for a compute resource")
      param :id, :identifier, :required => true
      def available_zones
        @available_zones = @compute_resource.available_zones
        @total = @available_zones&.size
        render :available_zones, :layout => 'api/v2/layouts/index_layout'
      end

      api :GET, "/compute_resources/:id/available_networks", N_("List available networks for a compute resource")
      api :GET, "/compute_resources/:id/available_clusters/:cluster_id/available_networks", N_("List available networks for a compute resource cluster")
      param :id, :identifier, :required => true
      param :cluster_id, String
      def available_networks
        @available_networks = @compute_resource.available_networks(params[:cluster_id].presence)
        @total = @available_networks&.size
        render :available_networks, :layout => 'api/v2/layouts/index_layout'
      end

      api :GET, "/compute_resources/:id/available_clusters/:cluster_id/available_resource_pools", N_("List resource pools for a compute resource cluster")
      param :id, :identifier, :required => true
      param :cluster_id, String, :required => true
      def available_resource_pools
        @available_resource_pools = @compute_resource.available_resource_pools({ :cluster_id => params[:cluster_id] })
        @total = @available_resource_pools&.size
        render :available_resource_pools, :layout => 'api/v2/layouts/index_layout'
      end

      api :GET, "/compute_resources/:id/storage_domains/:storage_domain_id", N_("List attributes for a given storage domain")
      param :id, :identifier, :required => true
      param :storage_domain_id, String, :required => true
      def storage_domain
        @storage_domain = @compute_resource.storage_domain(params[:storage_domain_id])
      end

      api :GET, "/compute_resources/:id/available_storage_domains", N_("List storage domains for a compute resource")
      api :GET, "/compute_resources/:id/available_storage_domains/:storage_domain", N_("List attributes for a given storage domain")
      api :GET, "/compute_resources/:id/available_clusters/:cluster_id/available_storage_domains", N_("List storage domains for a compute resource")
      param :id, :identifier, :required => true
      param :cluster_id, String
      param :storage_domain, String
      def available_storage_domains
        if params[:storage_domain]
          Foreman::Deprecation.api_deprecation_warning("use /compute_resources/:id/storage_domain/:storage_domain_id endpoind instead")
          @available_storage_domains = [@compute_resource.storage_domain(params[:storage_domain])]
        else
          @available_storage_domains = @compute_resource.available_storage_domains(params[:cluster_id].presence)
        end
        @total = @available_storage_domains&.size
        render :available_storage_domains, :layout => 'api/v2/layouts/index_layout'
      end

      api :GET, "/compute_resources/:id/storage_pods/:storage_pod_id", N_("List attributes for a given storage pod")
      param :id, :identifier, :required => true
      param :storage_pod_id, String, :required => true
      def storage_pod
        @storage_pod = @compute_resource.storage_pod(params[:storage_pod_id])
      end

      api :GET, "/compute_resources/:id/available_storage_pods", N_("List storage pods for a compute resource")
      api :GET, "/compute_resources/:id/available_storage_pods/:storage_pod", N_("List attributes for a given storage pod")
      api :GET, "/compute_resources/:id/available_clusters/:cluster_id/available_storage_pods", N_("List storage pods for a compute resource")
      param :id, :identifier, :required => true
      param :cluster_id, String
      param :storage_pod, String
      def available_storage_pods
        if params[:storage_pod]
          Foreman::Deprecation.api_deprecation_warning("use /compute_resources/:id/storage_pod/:storage_pod_id endpoind instead")
          @available_storage_pods = [@compute_resource.storage_pod(params[:storage_pod])]
        else
          @available_storage_pods = @compute_resource.available_storage_pods(params[:cluster_id].presence)
        end
        @total = @available_storage_pods&.size
        render :available_storage_pods, :layout => 'api/v2/layouts/index_layout'
      end

      api :GET, "/compute_resources/:id/available_security_groups", N_("List available security groups for a compute resource")
      param :id, :identifier, :required => true
      def available_security_groups
        @available_security_groups = @compute_resource.available_security_groups
        @total = @available_security_groups&.size
        render :available_security_groups, :layout => 'api/v2/layouts/index_layout'
      end

      api :PUT, "/compute_resources/:id/associate/", N_("Associate VMs to Hosts")
      param :id, :identifier, :required => true
      def associate
        if @compute_resource.supports_host_association?
          associator = ComputeResourceHostAssociator.new(@compute_resource)
          associator.associate_hosts
          @hosts = associator.hosts
          render 'api/v2/hosts/index', :layout => 'api/v2/layouts/index_layout'
        else
          render_message(_('Associating VMs is not supported for this compute resource'), :status => :unprocessable_entity)
        end
      end

      api :PUT, "/compute_resources/:id/refresh_cache/", N_("Refresh Compute Resource Cache")
      param :id, :identifier, :required => true
      def refresh_cache
        if @compute_resource.respond_to?(:refresh_cache)
          if @compute_resource.refresh_cache
            render_message(_('Successfully refreshed the cache.'))
          else
            render_message(_('Failed to refresh the cache.'), :status => :unprocessable_entity)
          end
        else
          raise ::Foreman::Exception.new(N_("Cache refreshing is not supported for %s"), @compute_resource.provider_friendly_name)
        end
      end

      api :GET, "/compute_resources/:id/available_virtual_machines/", N_("List available virtual machines for a compute resource")
      param :id, :identifier, :required => true
      def available_virtual_machines
        @available_virtual_machines = @compute_resource.vms.all
      end

      api :GET, "/compute_resources/:id/available_virtual_machines/:vm_id", N_("Show a virtual machine")
      param :id, :identifier, :required => true
      param :vm_id, :identifier, :required => true
      def show_vm
        begin
          @vm = @compute_resource.find_vm_by_uuid(params[:vm_id])
        rescue
          raise ::Foreman::Exception.new(N_("Virtual machine was not found by id %{vm_id}") % {:vm_id => params[:vm_id]})
        end
        attributes = @vm.attributes.deep_symbolize_keys
        attributes[:provider] = @compute_resource.provider
        render :json => attributes.as_json(:except => [:label_fingerprint, :fingerprint, :parent])
      end

      api :PUT, "/compute_resources/:id/available_virtual_machines/:vm_id/power", N_("Power a Virtual Machine")
      param :id, :identifier, :required => true
      param :vm_id, :identifier, :required => true
      def power_vm
        @vm = @compute_resource.find_vm_by_uuid(params[:vm_id])
        action = @vm.ready? ? :stop : :start
        @vm.send(action)
        render_message(_('%{action} %{vm}') % {:vm => @vm, :action => (action == :stop) ? _('stopping') : _('starting')})
      rescue Foreman::Exception => e
        render_exception(e, :status => :unprocessable_entity)
      end

      api :DELETE, "/compute_resources/:id/available_virtual_machines/:vm_id", N_("Delete a Virtual Machine")
      param :id, :identifier, :required => true
      param :vm_id, :identifier, :required => true
      def destroy_vm
        process_response @compute_resource.destroy_vm params[:vm_id]
      end

      private

      def action_permission
        case params[:action]
          when 'available_images', 'available_virtual_machines', 'available_clusters', 'available_flavors', 'available_folders', 'available_networks', 'available_resource_pools', 'available_security_groups', 'available_storage_domains', 'storage_domain', 'available_zones', 'associate', 'available_storage_pods', 'storage_pod', 'refresh_cache', 'show_vm', 'power_vm', 'destroy_vm'
            :view
          else
            super
        end
      end
    end
  end
end
