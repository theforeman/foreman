module Api
  module V2
    class AutosignController < V2::BaseController
      before_action :find_required_nested_object, :setup_proxy

      api :GET, "/smart_proxies/:smart_proxy_id/autosign", N_("List all autosign entries")

      def index
        autosign = @api.autosign
        render :json => { root_node_name => autosign }
      end

      api :POST, "/smart_proxies/:smart_proxy_id/autosign", N_("Create autosign entry")
      param :id, String, :required => true, :desc => N_("Autosign entry name")

      def create
        autosign = @api.set_autosign(params[:id])
        render :json => { root_node_name => autosign }
      rescue ProxyAPI::ProxyException => e
        handle_proxy_error e
      end

      api :DELETE, "/smart_proxies/:smart_proxy_id/autosign/:id", N_("Delete autosign entry")
      param :id, String, :required => true, :desc => N_("Autosign entry name")

      def destroy
        autosign = @api.del_autosign(params[:id])
        render :json => { root_node_name => autosign }
      rescue ProxyAPI::ProxyException => e
        handle_proxy_error e
      end

      private

      def setup_proxy
        @api = ProxyAPI::Puppetca.new({:url => @nested_obj.url})
      end

      def allowed_nested_id
        %w(smart_proxy_id)
      end

      def handle_proxy_error(exception)
        render :status => :internal_server_error, :json => { error: exception.message }
      end
    end
  end
end
