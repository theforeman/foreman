module Api
  module V2
    class HostnamesController < V2::BaseController
      include Api::Version2
      include Api::TaxonomyScope
      include Foreman::Controller::Parameters::Hostname

      resource_description do
        desc <<-DOC
          Foreman use Smart Proxy Hostnames to configure Hosts to communicate with a Proxy with
          Generally you would have 1 Hostname per Smart Proxy, but if you have a Smart Proxy
          serving multiple networks with multiple interfaces or a load balanced Smart Proxy
          then you will probably want more than 1 per Smart Proxy or 1 shared between 2 Smart Proxies.
        DOC
      end

      before_action :find_resource, :only => %w{show update destroy}

      api :GET, '/hostnames', N_("List of hostnames")
      api :GET, "/locations/:location_id/hostnames", N_("List of hostnames per location")
      api :GET, "/organizations/:organization_id/hostnames", N_("List of hostnames per organization")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @hostnames = resource_scope_for_index
      end

      api :GET, "/hostnames/:id/", N_("Show a hostname")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :hostname do
        param :hostname, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_("The hostname name")
          param :hostname, String, :required => true, :desc => N_("The fully qualified hostname")
          param :smart_proxy_ids, Array, :required => false, :desc => N_("Smart Proxies that use this hostname")
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, '/hostnames', N_("Create a hostname")
      param_group :hostname, :as => :create

      def create
        @hostname = Hostname.new(hostname_params)
        process_response @hostname.save
      end

      api :PUT, '/hostnames/:id', N_("Update a hostname")
      param :id, :number, :desc => N_("Hostname numeric identifier"), :required => true
      param_group :hostname

      def update
        process_response @hostname.update_attributes(hostname_params)
      end

      api :DELETE, '/hostnames/:id', N_("Delete a hostname")
      param :id, :number, :desc => N_("Hostname numeric identifier"), :required => true

      def destroy
        process_response @hostname.destroy
      end

      private

      def allowed_nested_id
        %w(hostname_id location_id organization_id)
      end
    end
  end
end
