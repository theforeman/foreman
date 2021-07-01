module Api
  module V2
    class InstanceHostsController < V2::BaseController
      def resource_class
        @resource_class ||= Host::Managed
      end

      def resource_scope(*args)
        super.authorized(:view_hosts).joins(:infrastructure_facet).merge(::HostFacets::InfrastructureFacet.where(foreman: true))
      end

      api :PUT, '/instance/hosts/:host_id', N_("Assign a host to the Foreman instance")
      param :host_id, :identifier_dottable
      def update
        # We cannot use resource scope as that is scoped only to hosts which already have the facet
        host = ::Host::Managed.friendly.find(params[:id])
        facet = host.infrastructure_facet || host.build_infrastructure_facet
        facet.foreman = true
        facet.save!
        render status: :created, body: ''
      end

      api :DESTROY, '/instance/hosts/:host_id', N_("Unassign a given host from the Foreman instance")
      def destroy
        host = resource_scope.friendly.find_by(id: params[:id])
        facet = host&.infrastructure_facet
        return if facet.nil?

        facet.foreman = false
        facet.save!
      end
    end
  end
end
