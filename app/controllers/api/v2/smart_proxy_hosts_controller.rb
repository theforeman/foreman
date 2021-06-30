module Api
  module V2
    class SmartProxyHostsController < V2::BaseController
      before_action :find_proxy

      def resource_class
        @resource_class ||= Host::Managed
      end

      def resource_scope(*args)
        ::Host::Managed.joins(:infrastructure_facet).merge(::HostFacets::InfrastructureFacet.where(smart_proxy_id: @proxy.id))
      end

      api :GET, '/smart_proxies/:smart_proxy_id/hosts', N_("Get hosts forming the Foreman instance")
      def index
        # TODO: Permissions and taxonomies
        @hosts = resource_scope_for_index
        render 'api/v2/hosts/index'
      end

      api :PUT, '/smart_proxies/:smart_proxy_id/hosts/:host_id', N_("Assign a host to the Foreman instance")
      param :smart_proxy_id, :identifier
      param :host_id, :identifier
      def update
        # TODO: Permissions and taxonomies
        # TODO?: output
        # We cannot use resource scope as that is scoped only to hosts which already have the facet
        host = ::Host::Managed.friendly.find(params[:id])
        facet = host.infrastructure_facet || host.build_infrastructure_facet
        facet.smart_proxy_id = @proxy.id
        facet.save!
        render status: :created, body: ''
      end

      api :DELETE, '/smart_proxies/:smart_proxy_id/hosts/:host_id', N_("Unassign a given host from the Foreman instance")
      def destroy
        # TODO: Permissions and taxonomies
        host = resource_scope.friendly.try(:find, params[:id])
        facet = host&.infrastructure_facet
        return if facet.nil?

        facet.smart_proxy_id = nil
        facet.save!
      end

      def find_proxy
        @proxy ||= ::SmartProxy.find(params[:smart_proxy_id])
      end
    end
  end
end
