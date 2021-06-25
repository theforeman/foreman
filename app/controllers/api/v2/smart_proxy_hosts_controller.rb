module Api
  module V2
    class SmartProxyHostsController < V2::BaseController
      before_action :require_admin, :only => [:destroy, :update]
      before_action :find_proxy

      def resource_class
        @resource_class ||= Host::Managed
      end

      def resource_scope(*args)
        resource_class.authorized(:view_hosts).joins(:infrastructure_facet).merge(::HostFacets::InfrastructureFacet.where(smart_proxy_id: @proxy.id))
      end

      api :PUT, '/smart_proxies/:smart_proxy_id/hosts/:host_id', N_("Assign a host to the smart proxy")
      param :smart_proxy_id, :identifier
      param :host_id, :identifier
      def update
        # We cannot use resource scope as that is scoped only to hosts which already have the facet
        host = resource_class.authorized(:view_hosts).friendly.find(params[:id])
        facet = host.infrastructure_facet || host.build_infrastructure_facet
        facet.smart_proxy_id = @proxy.id
        changed = facet.changes.key? 'smart_proxy_id'
        facet.save!
        respond_with '', :responder => ApiResponder, :status => changed ? :created : :ok
      end

      api :GET, '/smart_proxies/:smart_proxy_id/hosts', N_("Get hosts forming the smart proxy")
      def index
        @hosts = resource_scope_for_index
        render 'api/v2/hosts/index'
      end

      api :DELETE, '/smart_proxies/:smart_proxy_id/hosts/:host_id', N_("Unassign a given host from the smart proxy")
      def destroy
        facet = resource_scope.friendly.find(params[:id]).infrastructure_facet

        facet.smart_proxy_id = nil
        facet.save!

        respond_with '', :responder => ApiResponder, :status => :no_content
      end

      def find_proxy
        @proxy ||= ::SmartProxy.authorized(:view_smart_proxies).find(params[:smart_proxy_id])
      end
    end
  end
end
