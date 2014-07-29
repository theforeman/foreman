module Api
  module V2
    class AutosignController < V2::BaseController

      before_filter :find_required_nested_object, :setup_proxy

      api :GET, "/smart_proxies/smart_proxy_id/autosign", N_("List all autosign entries")

      def index
        autosign = @api.autosign
        render :json => { root_node_name => autosign }
      end

      private

      def setup_proxy
        @api = ProxyAPI::Puppetca.new({:url => @nested_obj.url})
      end

      def allowed_nested_id
        %w(smart_proxy_id)
      end

    end
  end
end
