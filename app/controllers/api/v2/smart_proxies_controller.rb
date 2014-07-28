module Api
  module V2
    class SmartProxiesController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope
      include Api::ImportPuppetclassesCommonController
      before_filter :find_resource, :only => %w{show update destroy refresh}

      api :GET, "/smart_proxies/", "List all smart_proxies."
      param :search, String, :desc => "Filter results"
      param :order, String, :desc => "Sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @smart_proxies = SmartProxy.authorized(:view_smart_proxies).includes(:features).
          search_for(*search_options).paginate(paginate_options)
        @total = SmartProxy.authorized(:view_smart_proxies).includes(:features).count
      end

      api :GET, "/smart_proxies/:id/", "Show a smart proxy."
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :smart_proxy do
        param :name, String, :required => true, :action_aware => true
        param :url, String, :required => true, :action_aware => true
      end

      api :POST, "/smart_proxies/", "Create a smart proxy."
      param_group :smart_proxy, :as => :create

      def create
        @smart_proxy = SmartProxy.new(params[:smart_proxy])
        process_response @smart_proxy.save
      end

      api :PUT, "/smart_proxies/:id/", "Update a smart proxy."
      param :id, String, :required => true
      param_group :smart_proxy

      def update
        process_response @smart_proxy.update_attributes(params[:smart_proxy])
      end

      api :DELETE, "/smart_proxies/:id/", "Delete a smart_proxy."
      param :id, String, :required => true

      def destroy
        process_response @smart_proxy.destroy
      end

      api :PUT, "/smart_proxies/:id/refresh", "Refresh smart proxy features"
      param :id, String, :required => true

      def refresh
        process_response @smart_proxy.refresh.blank? && @smart_proxy.save
      end

      private

      def action_permission
        case params[:action]
        when 'refresh'
          :edit
        else
          super
        end
      end

    end
  end
end
