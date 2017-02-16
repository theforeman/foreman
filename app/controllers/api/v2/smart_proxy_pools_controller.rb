module Api
  module V2
    class SmartProxyPoolsController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::Parameters::SmartProxyPool

      resource_description do
        desc <<-DOC
          Foreman uses Smart Proxy Pools to configure Hosts to communicate with a Smart Proxy.
          Generally you would have 1 Pool per Smart Proxy, but if you have a Smart Proxy
          serving multiple networks with multiple interfaces or a Smart Proxy cluster
          then you will want more than 1 Pool per Smart Proxy or 1 Pool shared between 2 Smart Proxies.
        DOC
      end

      before_action :find_resource, :only => %w{show update destroy}

      api :GET, '/smart_proxy_pools', N_("List Smart Proxy Pools")
      api :GET, "/locations/:location_id/smart_proxy_pools", N_("List Smart Proxy Pools per location")
      api :GET, "/organizations/:organization_id/smart_proxy_pools", N_("List Smart Proxy Pools per organization")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @smart_proxy_pools = resource_scope_for_index
      end

      api :GET, "/smart_proxy_pools/:id/", N_("Show a Smart Proxy Pool")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :smart_proxy_pool do
        param :smart_proxy_pool, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_("The Smart Proxy Pool name")
          param :hostname, String, :required => true, :desc => N_("The fully qualified hostname")
          param :smart_proxy_ids, Array, :required => false, :desc => N_("Smart Proxies that use this Pool")
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, '/smart_proxy_pools', N_("Create a Smart Proxy Pool")
      param_group :smart_proxy_pool, :as => :create

      def create
        @smart_proxy_pool = SmartProxyPool.new(smart_proxy_pool_params)
        process_response @smart_proxy_pool.save
      end

      api :PUT, '/smart_proxy_pools/:id', N_("Update a Smart Proxy Pool")
      param :id, :number, :desc => N_("Smart Proxy Pool numeric identifier"), :required => true
      param_group :smart_proxy_pool

      def update
        process_response @smart_proxy_pool.update(smart_proxy_pool_params)
      end

      api :DELETE, '/smart_proxy_pools/:id', N_("Delete a Smart Proxy Pool")
      param :id, :number, :desc => N_("Smart Proxy Pool numeric identifier"), :required => true

      def destroy
        process_response @smart_proxy_pool.destroy
      end

      private

      def allowed_nested_id
        %w(smart_proxy_pool_id location_id organization_id)
      end
    end
  end
end
