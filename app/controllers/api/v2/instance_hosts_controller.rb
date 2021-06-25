module Api
  module V2
    class InstanceHostsController < V2::BaseController
      before_action :require_admin, :only => [:destroy, :update]

      def resource_class
        @resource_class ||= Host::Managed
      end

      def resource_scope(*args)
        super.authorized(:view_hosts).joins(:infrastructure_facet).merge(::HostFacets::InfrastructureFacet.where(foreman_instance: true))
      end

      api :PUT, '/instance_hosts/:host_id', N_("Assign a host to the Foreman instance")
      param :host_id, :identifier_dottable
      def update
        # We cannot use resource scope as that is scoped only to hosts which already have the facet
        host = resource_class.friendly.find(params[:id])
        facet = host.infrastructure_facet || host.build_infrastructure_facet
        facet.foreman_instance = true
        changed = facet.changes.key? 'foreman_instance'
        facet.save!
        respond_with '', :responder => ApiResponder, :status => changed ? :created : :ok
      end

      api :GET, '/instance_hosts', N_('List hosts forming the Foreman instance')
      def index
        @hosts = resource_scope_for_index
        render 'api/v2/hosts/index'
      end

      api :DESTROY, '/instance_hosts/:host_id', N_("Unassign a given host from the Foreman instance")
      def destroy
        # Will raise ActiveRecord::RecordNotFound if the host does not exist or is not Foreman
        facet = resource_scope.friendly.find(params[:id]).infrastructure_facet

        facet.foreman_instance = false
        facet.save!
        respond_with '', :responder => ApiResponder, :status => :no_content
      end
    end
  end
end
