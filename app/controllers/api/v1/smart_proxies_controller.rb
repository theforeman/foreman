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

      api :POST, "/smart_proxies/", "Create a smart proxy."
      param :smart_proxy, Hash, :required => true do
        param :name, String, :required => true
        param :url, String, :required => true
      end
      def create
        @smart_proxy = SmartProxy.new(params[:smart_proxy])
        process_response @smart_proxy.save
      end

      api :PUT, "/smart_proxies/:id/", "Update a smart proxy."
      param :id, String, :required => true
      param :smart_proxy, Hash, :required => true do
        param :name, String, :required => true
        param :url, String, :required => true
      end
      def update
        process_response @smart_proxy.update_attributes(params[:smart_proxy])
      end

      api :DELETE, "/smart_proxies/:id/", "Delete a smart_proxy."
      param :id, String, :required => true
      def destroy
        process_response @smart_proxy.destroy
      end

    end
  end
end
