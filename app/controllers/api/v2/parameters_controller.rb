module Api
  module V2
    class ParametersController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_required_nested_object
      before_filter :find_parameter, :only => [:show, :update, :destroy]

      resource_description do
        # TRANSLATORS: API documentation - do not translate
        desc <<-DOC
          These API calls are related to <b>nested parameters for host, domain, hostgroup, operating system</b>. If you are looking for
          <a href="common_parameters.html">global parameters</a>, go to <a href="common_parameters.html">this link</a>.
        DOC
      end

      api :GET, "/hosts/:host_id/parameters", "List all parameters for host"
      api :GET, "/hostgroups/:hostgroup_id/parameters", "List all parameters for hostgroup"
      api :GET, "/domains/:domain_id/parameters", "List all parameters for domain"
      api :GET, "/operatingsystems/:operatingsystem_id/parameters", "List all parameters for operating system"
      api :GET, "/locations/:location_id/parameters", "List all parameters for location"
      api :GET, "/organizations/:organization_id/parameters", "List all parameters for organization"
      param :host_id, String, :desc => "id of host"
      param :hostgroup_id, String, :desc => "id of hostgroup"
      param :domain_id, String, :desc => "id of domain"
      param :operatingsystem_id, String, :desc => "id of operating system"
      param :location_id, String, :desc => "id of location"
      param :organization_id, String, :desc => "id of organization"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @parameters = nested_obj.send(parameters_method).paginate(paginate_options)
        @total = nested_obj.send(parameters_method).count
      end

      api :GET, "/hosts/:host_id/parameters/:id", "Show a nested parameter for host"
      api :GET, "/hostgroups/:hostgroup_id/parameters/:id", "Show a nested parameter for hostgroup"
      api :GET, "/domains/:domain_id/parameters/:id", "Show a nested parameter for domain"
      api :GET, "/operatingsystems/:operatingsystem_id/parameters/:id", "Show a nested parameter for operating system"
      api :GET, "/locations/:location_id/parameters/:id", "Show a nested parameter for location"
      api :GET, "/organizations/:organization_id/parameters/:id", "Show a nested parameter for organization"
      param :host_id, String, :desc => "id of host"
      param :hostgroup_id, String, :desc => "id of hostgroup"
      param :domain_id, String, :desc => "id of domain"
      param :operatingsystem_id, String, :desc => "id of operating system"
      param :location_id, String, :desc => "id of location"
      param :organization_id, String, :desc => "id of organization"
      param :id, String, :required => true, :desc => "id of parameter"

      def show
      end

      def_param_group :parameter do
        param :parameter, Hash, :action_aware => true do
          param :name, String, :required => true
          param :value, String, :required => true
        end
      end

      api :POST, "/hosts/:host_id/parameters/", "Create a nested parameter for host"
      api :POST, "/hostgroups/:hostgroup_id/parameters/", "Create a nested parameter for hostgroup"
      api :POST, "/domains/:domain_id/parameters/", "Create a nested parameter for domain"
      api :POST, "/operatingsystems/:operatingsystem_id/parameters/", "Create a nested parameter for operating system"
      api :POST, "/locations/:location_id/parameters/", "Create a nested parameter for location"
      api :POST, "/organizations/:organization_id/parameters/", "Create a nested parameter for organization"
      param :host_id, String, :desc => "id of host"
      param :hostgroup_id, String, :desc => "id of hostgroup"
      param :domain_id, String, :desc => "id of domain"
      param :operatingsystem_id, String, :desc => "id of operating system"
      param :location_id, String, :desc => "id of location"
      param :organization_id, String, :desc => "id of organization"
      param_group :parameter, :as => :create

      def create
        @parameter = nested_obj.send(parameters_method).new(params[:parameter])
        process_response @parameter.save
      end

      api :PUT, "/hosts/:host_id/parameters/:id", "Update a nested parameter for host"
      api :PUT, "/hostgroups/:hostgroup_id/parameters/:id", "Update a nested parameter for hostgroup"
      api :PUT, "/domains/:domain_id/parameters/:id", "Update a nested parameter for domain"
      api :PUT, "/operatingsystems/:operatingsystem_id/parameters/:id", "Update a nested parameter for operating system"
      api :PUT, "/locations/:location_id/parameters/:id", "Update a nested parameter for location"
      api :PUT, "/organizations/:organization_id/parameters/:id", "Update a nested parameter for organization"
      param :host_id, String, :desc => "id of host"
      param :hostgroup_id, String, :desc => "id of hostgroup"
      param :domain_id, String, :desc => "id of domain"
      param :operatingsystem_id, String, :desc => "id of operating system"
      param :location_id, String, :desc => "id of location"
      param :organization_id, String, :desc => "id of organization"
      param :id, String, :required => true, :desc => "id of parameter"
      param_group :parameter

      def update
        process_response @parameter.update_attributes(params[:parameter])
      end

      api :DELETE, "/hosts/:host_id/parameters/:id", "Delete a nested parameter for host"
      api :DELETE, "/hostgroups/:hostgroup_id/parameters/:id", "Delete a nested parameter for hostgroup"
      api :DELETE, "/domains/:domain_id/parameters/:id", "Delete a nested parameter for domain"
      api :DELETE, "/operatingsystems/:operatingsystem_id/parameters/:id", "Delete a nested parameter for operating system"
      api :DELETE, "/locations/:location_id/parameters/:id", "Delete a nested parameter for location"
      api :DELETE, "/organizations/:organization_id/parameters/:id", "Delete a nested parameter for organization"
      param :host_id, String, :desc => "id of host"
      param :hostgroup_id, String, :desc => "id of hostgroup"
      param :domain_id, String, :desc => "id of domain"
      param :operatingsystem_id, String, :desc => "id of operating system"
      param :location_id, String, :desc => "id of location"
      param :organization_id, String, :desc => "id of organization"
      param :id, String, :required => true, :desc => "id of parameter"

      def destroy
        process_response @parameter.destroy
      end

      api :DELETE, "/hosts/:host_id/parameters", "Delete all nested parameters for host"
      api :DELETE, "/hostgroups/:hostgroup_id/parameters", "Delete all nested parameters for hostgroup"
      api :DELETE, "/domains/:domain_id/parameters", "Delete all nested parameters for domain"
      api :DELETE, "/operatingsystems/:operatingsystem_id/parameters", "Delete all nested parameters for operating system"
      api :DELETE, "/locations/:location_id/parameters", "Delete all nested parameter for location"
      api :DELETE, "/organizations/:organization_id/parameters", "Delete all nested parameter for organization"
      param :host_id, String, :desc => "id of host"
      param :hostgroup_id, String, :desc => "id of hostgroup"
      param :domain_id, String, :desc => "id of domain"
      param :operatingsystem_id, String, :desc => "id of operating system"
      param :location_id, String, :desc => "id of location"
      param :organization_id, String, :desc => "id of organization"

      def reset
        @parameter = nested_obj.send(parameters_method)
        process_response @parameter.destroy_all
      end

      private

      def action_permission
        case params[:action]
          when 'reset'
            :destroy
          else
            super
        end
      end

      def parameters_method
        # hostgroup.rb has a method def parameters, so I didn't create has_many :parameters like Host, Domain, Os
        nested_obj.is_a?(Hostgroup) ? :group_parameters : :parameters
      end

      def allowed_nested_id
        %w(host_id hostgroup_id domain_id operatingsystem_id location_id organization_id)
      end

      def find_parameter
        # nested_obj is required, so no need to check here
        @parameters  = nested_obj.send(parameters_method)
        @parameter   = @parameters.find_by_id(params[:id].to_i) if params[:id].to_i > 0
        @parameter ||= @parameters.find_by_name(params[:id])
        return @parameter if @parameter
        not_found
      end

    end
  end
end
