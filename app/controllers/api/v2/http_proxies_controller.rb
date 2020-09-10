module Api
  module V2
    class HttpProxiesController < V2::BaseController
      include ::Api::Version2
      include Foreman::Controller::Parameters::HttpProxy

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w(show update destroy)

      api :GET, '/http_proxies/', N_('List of HTTP Proxies')
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(HttpProxy)
      def index
        @http_proxies = resource_scope_for_index
      end

      api :GET, '/http_proxies/:id/', N_('Show an HTTP Proxy')
      param :id, :identifier, :required => true, :desc => N_('Identifier of the HTTP Proxy')
      def show
      end

      def_param_group :http_proxy do
        param :http_proxy, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_('The HTTP Proxy name')
          param :url, String, :required => true, :desc => N_('URL of the HTTP Proxy')
          param :username, String, :required => false, :desc => N_('Username used to authenticate with the HTTP Proxy')
          param :password, String, :required => false, :desc => N_('Password used to authenticate with the HTTP Proxy')
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, '/http_proxies/', N_('Create an HTTP Proxy')
      param_group :http_proxy, :as => :create
      def create
        @http_proxy = HttpProxy.new(http_proxy_params)
        process_response @http_proxy.save
      end

      api :PUT, '/http_proxies/:id/', N_('Update an HTTP Proxy')
      param :id, :identifier, :required => true
      param_group :http_proxy
      def update
        process_response @http_proxy.update(http_proxy_params)
      end

      api :DELETE, '/http_proxies/:id/', N_('Delete an HTTP Proxy')
      param :id, :identifier, :required => true
      def destroy
        process_response @http_proxy.destroy
      end

      private

      def allowed_nested_id
        %w(location_id organization_id)
      end

      def resource_class
        HttpProxy
      end
    end
  end
end
