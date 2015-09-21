module Api
  module V2
    class DomainsController < V2::BaseController
      include Api::Version2
      include Api::TaxonomyScope

      resource_description do
        desc <<-DOC
          Foreman considers a domain and a DNS zone as the same thing. That is, if you
          are planning to manage a site where all the machines are or the form
          <i>hostname</i>.<b>somewhere.com</b> then the domain is <b>somewhere.com</b>.
          This allows Foreman to associate a puppet variable with a domain/site
          and automatically append this variable to all external node requests made
          by machines at that site.
        DOC
      end

      before_filter :find_optional_nested_object
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/domains/", N_("List of domains")
      api :GET, "/subnets/:subnet_id/domains", N_("List of domains per subnet")
      api :GET, "/locations/:location_id/domains", N_("List of domains per location")
      api :GET, "/organizations/:organization_id/domains", N_("List of domains per organization")
      param :subnet_id, String, :desc => N_("ID of subnet")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @domains = resource_scope_for_index
      end

      api :GET, "/domains/:id/", N_("Show a domain")
      param :id, :identifier, :required => true, :desc => N_("Numerical ID or domain name")

      def show
      end

      def_param_group :domain do
        param :domain, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_("The full DNS domain name")
          param :fullname, String, :required => false, :allow_nil => true, :desc => N_("Description of the domain")
          param :dns_id, :number, :required => false, :allow_nil => true, :desc => N_("DNS proxy to use within this domain")
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
        @domain = Domain.new(foreman_params)
        process_response @domain.save
      end

      api :PUT, "/domains/:id/", N_("Update a domain")
      param :id, :identifier, :required => true
      param_group :domain

      def update
        process_response @domain.update_attributes(foreman_params)
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
    end
  end
end
