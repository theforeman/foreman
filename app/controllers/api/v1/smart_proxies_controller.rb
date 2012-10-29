module Api
  module V1
    class SmartProxiesController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/smart_proxies/", "List all smart_proxies."
      def index
        @smart_proxies = SmartProxy.includes(:features).paginate(:page => params[:page])
      end

      api :GET, "/smart_proxies/:id/", "Show a smart proxy."
      param :id, :identifier, :required => true
      def show
      end

    end
  end
end
