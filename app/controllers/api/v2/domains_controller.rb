module Api
  module V2
    class DomainsController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::Parameters::Domain
      include ParameterAttributes

      resource_description do
        desc <<-DOC
          Foreman considers a domain and a DNS zone as the same thing. That is, if you
          are planning to manage a site where all the machines are of the form
          <i>hostname</i>.<b>somewhere.com</b> then the domain is <b>somewhere.com</b>.
          This allows Foreman to associate a puppet variable with a domain/site
          and automatically append this variable to all external node requests made
          by machines at that site.
        DOC
        param :location_id, Integer, :required => false, :desc => N_("Set the current location context for the request")
        param :organization_id, Integer, :required => false, :desc => N_("Set the current organization context for the request")
      end

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show update destroy}
      before_action :process_parameter_attributes, :only => %w{update}

      api :GET, "/domains/", N_("List of domains")
      api :GET, "/subnets/:subnet_id/domains", N_("List of domains per subnet")
      api :GET, "/locations/:location_id/domains", N_("List of domains per location")
      api :GET, "/organizations/:organization_id/domains", N_("List of domains per organization")
      param :subnet_id, String, :desc => N_("ID of subnet")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Domain)

      def index
        @domains = resource_scope_for_index
      end

      api :GET, "/domains/:id/", N_("Show a domain")
      param :id, :identifier, :required => true, :desc => N_("Numerical ID or domain name")
      param :show_hidden_parameters, :bool, :desc => N_("Display hidden parameter values")

      def show
      end

      def_param_group :domain do
        param :domain, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_("The full DNS domain name")
          param :fullname, String, :required => false, :allow_nil => true, :desc => N_("Description of the domain")
          Domain.registered_smart_proxies.each do |name, options|
            param :"#{name}_id", :number, :required => false, :allow_nil => true, :desc => options[:api_description]
          end
          param :domain_parameters_attributes, Array, :required => false, :desc => N_("Array of parameters (name, value)")
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, "/domains/", N_("Create a domain")
      description <<-DOC
        The <b>fullname</b> field is used for human readability in reports
        and other pages that refer to domains, and also available as
        an external node parameter
      DOC
      param_group :domain, :as => :create

      def create
        @domain = Domain.new(domain_params)
        if verify_proxy_id(domain_params[:dns_id])
          process_response @domain.save
        else
          @domain.errors.add(:dns_id, _('Invalid smart-proxy id'))
          process_resource_error
        end
      end

      api :PUT, "/domains/:id/", N_("Update a domain")
      param :id, :identifier, :required => true
      param_group :domain

      def update
        if verify_proxy_id(domain_params[:dns_id])
          process_response @domain.update(domain_params)
        else
          @domain.errors.add(:dns_id, _('Invalid smart-proxy id'))
          process_resource_error
        end
      end

      api :DELETE, "/domains/:id/", N_("Delete a domain")
      param :id, :identifier, :required => true

      def destroy
        process_response @domain.destroy
      end

      private

      def allowed_nested_id
        %w(subnet_id location_id organization_id)
      end

      def verify_proxy_id(id)
        id.nil? || SmartProxy.authorized(:view_smart_proxies).find_by_id(id).present?
      end
    end
  end
end
