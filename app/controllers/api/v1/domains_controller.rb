module Api
  module V1
    class DomainsController < V1::BaseController
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

      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/domains/", "List of domains"
      param :search, String, :desc => "Filter results"
      param :order, String, :desc => "Sort results"
      def index
        @domains = Domain.search_for(params[:search], :order => params[:order])
      end

      api :GET, "/domains/:id/", "Show a domain."
      def show
      end

      api :POST, "/domains/", "Create a domain."
      description <<-DOC
        The <b>fullname</b> field is used for human readability in reports
        and other pages that refer to domains, and also available as
        an external node parameter
      DOC
      param :domain, Hash, :required => true do
        param :name, String, :required => true, :desc => "The full DNS Domain name"
        param :fullname, String, :required => false, :desc => "Full name describing the domain"
        param :dns_id, :number, :required => false, :desc => "DNS Proxy to use within this domain"
        param :domain_parameters_attributes, Array, :required => false, :desc => "Array of parameters (name, value)"
      end
      def create
        @domain = Domain.new(params[:domain])
        process_response @domain.save
      end

      api :PUT, "/domains/:id/", "Update a domain."
      param :domain, Hash, :required => true do
        param :name, String, :required => true, :desc => "The full DNS Domain name"
        param :fullname, String, :required => false, :desc => "Full name describing the domain"
        param :dns_id, :number, :required => false, :desc => "DNS Proxy to use within this domain"
        param :domain_parameters_attributes, Array, :required => false, :desc => "Array of parameters (name, value)"
      end
      def update
        process_response @domain.update_attributes(params[:domain])
      end

      api :DELETE, "/domains/:id/", "Delete a domain."
      def destroy
        process_response @domain.destroy
      end
    end
  end
end
