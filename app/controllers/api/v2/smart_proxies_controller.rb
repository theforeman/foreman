module Api
  module V2
    class SmartProxiesController < V2::BaseController
      include Api::Version2
      include Api::TaxonomyScope
      include Api::ImportPuppetclassesCommonController
      before_filter :find_resource, :only => %w{show update destroy refresh}

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
        @smart_proxy = SmartProxy.new(foreman_params)
        process_response @smart_proxy.save
      end

      api :PUT, "/smart_proxies/:id/", N_("Update a smart proxy")
      param :id, String, :required => true
      param_group :smart_proxy

      def update
        process_response @smart_proxy.update_attributes(foreman_params)
      end

      api :DELETE, "/smart_proxies/:id/", N_("Delete a smart proxy")
      param :id, String, :required => true

      def destroy
        process_response @smart_proxy.destroy
      end

      api :PUT, "/smart_proxies/:id/refresh", N_("Refresh smart proxy features")
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
