module Api
  module V2
    class SmartProxiesController < V2::BaseController
      include Api::Version2
      include Api::TaxonomyScope
      include Api::ImportPuppetclassesCommonController
      include Foreman::Controller::SmartProxyAuth

      add_smart_proxy_filters :refresh

      before_filter :find_resource, :only => %w{show update destroy refresh version}

      api :GET, "/smart_proxies/", N_("List all smart proxies")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @smart_proxies = resource_scope_for_index.includes(:features)
      end

      api :GET, "/smart_proxies/:id/", N_("Show a smart proxy")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :smart_proxy do
        param :smart_proxy, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :url, String, :required => true
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, "/smart_proxies/", N_("Create a smart proxy")
      param_group :smart_proxy, :as => :create

      def create
        @smart_proxy = SmartProxy.new(params[:smart_proxy])
        process_response @smart_proxy.save
      end

      api :PUT, "/smart_proxies/:id/", N_("Update a smart proxy")
      param :id, String, :required => true
      param_group :smart_proxy

      def update
        process_response @smart_proxy.update_attributes(params[:smart_proxy])
      end

      api :DELETE, "/smart_proxies/:id/", N_("Delete a smart proxy")
      param :id, String, :required => true

      def destroy
        process_response @smart_proxy.destroy
      end

      api :PUT, "/smart_proxies/:id/refresh", N_("Refresh smart proxy features")
      param :id, String, :required => true

      def refresh
        process_response @smart_proxy.refresh
      end

      def version
        begin
          version = @smart_proxy.version
        rescue Foreman::Exception => exception
          render :version, :locals => {:success => false, :message => exception.message} and return
        end
        render :version, :locals => {:success => true, :message => version[:message]}
      end

      private

      def action_permission
        case params[:action]
        when 'refresh'
          :edit
        when 'version'
          :view
        else
          super
        end
      end

      #proxy has no clue about its id
      def find_resource
        if params[:startup_refresh]
          @smart_proxy = SmartProxy.find_by_name params[:proxy_name]
        else
          super
        end
      end
    end
  end
end
