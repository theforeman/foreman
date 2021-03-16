module Api
  module V2
    class ParametersController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::Parameters::Parameter

      before_action :find_required_nested_object
      before_action :find_parameter, :only => [:show, :update, :destroy]

      resource_description do
        desc <<-DOC
          These API calls are related to <b>nested parameters for a host, domain, subnet, host group, operating system</b>. If you are looking for
          <a href="common_parameters.html">global parameters</a>, go to <a href="common_parameters.html">this link</a>.
        DOC
      end

      api :GET, "/hosts/:host_id/parameters", N_("List all parameters for a host")
      api :GET, "/hostgroups/:hostgroup_id/parameters", N_("List all parameters for a host group")
      api :GET, "/domains/:domain_id/parameters", N_("List all parameters for a domain")
      api :GET, "/operatingsystems/:operatingsystem_id/parameters", N_("List all parameters for an operating system")
      api :GET, "/locations/:location_id/parameters", N_("List all parameters for a location")
      api :GET, "/organizations/:organization_id/parameters", N_("List all parameters for an organization")
      api :GET, "/subnets/:subnet_id/parameters", N_("List all parameters for a subnet")
      param :host_id, String, :desc => N_("ID of host")
      param :hostgroup_id, String, :desc => N_("ID of host group")
      param :domain_id, String, :desc => N_("ID of domain")
      param :operatingsystem_id, :number, :desc => N_("ID of operating system")
      param :location_id, String, :desc => N_("ID of location")
      param :organization_id, String, :desc => N_("ID of organization")
      param :subnet_id, String, :desc => N_("ID of subnet")
      param :show_hidden, :bool, :desc => N_("Display hidden values")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Parameter)

      def index
        base = nested_obj.send(parameters_method).authorized(current_permission)
        @parameters = base.search_for(*search_options).paginate(paginate_options)
        @total = base.count
      end

      api :GET, "/hosts/:host_id/parameters/:id", N_("Show a nested parameter for a host")
      api :GET, "/hostgroups/:hostgroup_id/parameters/:id", N_("Show a nested parameter for a host group")
      api :GET, "/domains/:domain_id/parameters/:id", N_("Show a nested parameter for a domain")
      api :GET, "/operatingsystems/:operatingsystem_id/parameters/:id", N_("Show a nested parameter for an operating system")
      api :GET, "/locations/:location_id/parameters/:id", N_("Show a nested parameter for a location")
      api :GET, "/organizations/:organization_id/parameters/:id", N_("Show a nested parameter for an organization")
      api :GET, "/subnets/:subnet_id/parameters/:id", N_("Show a nested parameter for a subnet")
      param :host_id, String, :desc => N_("ID of host")
      param :hostgroup_id, String, :desc => N_("ID of host group")
      param :domain_id, String, :desc => N_("ID of domain")
      param :operatingsystem_id, :number, :desc => N_("ID of operating system")
      param :location_id, String, :desc => N_("ID of location")
      param :organization_id, String, :desc => N_("ID of organization")
      param :subnet_id, String, :desc => N_("ID of subnet")
      param :id, String, :required => true, :desc => N_("ID of parameter")
      param :show_hidden, :bool, :desc => N_("Display hidden values")

      def show
      end

      def_param_group :parameter do
        param :parameter, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :value, String, :required => true
          param :parameter_type, Parameter::KEY_TYPES, :desc => N_("Type of value"), :required => true
        end
      end

      api :POST, "/hosts/:host_id/parameters/", N_("Create a nested parameter for a host")
      api :POST, "/hostgroups/:hostgroup_id/parameters/", N_("Create a nested parameter for a host group")
      api :POST, "/domains/:domain_id/parameters/", N_("Create a nested parameter for a domain")
      api :POST, "/operatingsystems/:operatingsystem_id/parameters/", N_("Create a nested parameter for an operating system")
      api :POST, "/locations/:location_id/parameters/", N_("Create a nested parameter for a location")
      api :POST, "/organizations/:organization_id/parameters/", N_("Create a nested parameter for an organization")
      api :POST, "/subnets/:subnet_id/parameters/", N_("Create a nested parameter for a subnet")
      param :host_id, String, :desc => N_("ID of host")
      param :hostgroup_id, String, :desc => N_("ID of host group")
      param :domain_id, String, :desc => N_("ID of domain")
      param :operatingsystem_id, :number, :desc => N_("ID of operating system")
      param :location_id, String, :desc => N_("ID of location")
      param :organization_id, String, :desc => N_("ID of organization")
      param :subnet_id, String, :desc => N_("ID of subnet")
      param_group :parameter, :as => :create

      def create
        @parameter = nested_obj.send(parameters_method).new(parameter_params(::Parameter))
        process_response @parameter.save
      end

      api :PUT, "/hosts/:host_id/parameters/:id", N_("Update a nested parameter for a host")
      api :PUT, "/hostgroups/:hostgroup_id/parameters/:id", N_("Update a nested parameter for a host group")
      api :PUT, "/domains/:domain_id/parameters/:id", N_("Update a nested parameter for a domain")
      api :PUT, "/operatingsystems/:operatingsystem_id/parameters/:id", N_("Update a nested parameter for an operating system")
      api :PUT, "/locations/:location_id/parameters/:id", N_("Update a nested parameter for a location")
      api :PUT, "/organizations/:organization_id/parameters/:id", N_("Update a nested parameter for an organization")
      api :PUT, "/subnets/:subnet_id/parameters/:id", N_("Update a nested parameter for a subnet")
      param :host_id, String, :desc => N_("ID of host")
      param :hostgroup_id, String, :desc => N_("ID of host group")
      param :domain_id, String, :desc => N_("ID of domain")
      param :operatingsystem_id, :number, :desc => N_("ID of operating system")
      param :location_id, String, :desc => N_("ID of location")
      param :organization_id, String, :desc => N_("ID of organization")
      param :id, String, :required => true, :desc => N_("ID of parameter")
      param :subnet_id, String, :desc => N_("ID of subnet")
      param_group :parameter

      def update
        process_response @parameter.update(parameter_params(::Parameter))
      end

      api :DELETE, "/hosts/:host_id/parameters/:id", N_("Delete a nested parameter for a host")
      api :DELETE, "/hostgroups/:hostgroup_id/parameters/:id", N_("Delete a nested parameter for a host group")
      api :DELETE, "/domains/:domain_id/parameters/:id", N_("Delete a nested parameter for a domain")
      api :DELETE, "/operatingsystems/:operatingsystem_id/parameters/:id", N_("Delete a nested parameter for an operating system")
      api :DELETE, "/locations/:location_id/parameters/:id", N_("Delete a nested parameter for a location")
      api :DELETE, "/organizations/:organization_id/parameters/:id", N_("Delete a nested parameter for an organization")
      api :DELETE, "/subnets/:subnet_id/parameters/:id", N_("Delete a nested parameter for a subnet")
      param :host_id, String, :desc => N_("ID of host")
      param :hostgroup_id, String, :desc => N_("ID of host group")
      param :domain_id, String, :desc => N_("ID of domain")
      param :operatingsystem_id, :number, :desc => N_("ID of operating system")
      param :location_id, String, :desc => N_("ID of location")
      param :organization_id, String, :desc => N_("ID of organization")
      param :id, String, :required => true, :desc => N_("ID of parameter")
      param :subnet_id, String, :desc => N_("ID of subnet")

      def destroy
        process_response @parameter.destroy
      end

      api :DELETE, "/hosts/:host_id/parameters", N_("Delete all nested parameters for a host")
      api :DELETE, "/hostgroups/:hostgroup_id/parameters", N_("Delete all nested parameters for a host group")
      api :DELETE, "/domains/:domain_id/parameters", N_("Delete all nested parameters for a domain")
      api :DELETE, "/operatingsystems/:operatingsystem_id/parameters", N_("Delete all nested parameters for an operating system")
      api :DELETE, "/locations/:location_id/parameters", N_("Delete all nested parameter for a location")
      api :DELETE, "/organizations/:organization_id/parameters", N_("Delete all nested parameter for an organization")
      api :DELETE, "/subnets/:subnet_id/parameters", N_("Delete all nested parameters for a subnet")
      param :host_id, String, :desc => N_("ID of host")
      param :hostgroup_id, String, :desc => N_("ID of host group")
      param :domain_id, String, :desc => N_("ID of domain")
      param :operatingsystem_id, :number, :desc => N_("ID of operating system")
      param :location_id, String, :desc => N_("ID of location")
      param :organization_id, String, :desc => N_("ID of organization")
      param :subnet_id, String, :desc => N_("ID of subnet")

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

      def controller_permission
        'params'
      end

      def parameters_method
        # hostgroup.rb has a method def parameters, so I didn't create has_many :parameters like Host, Domain, Os
        # locations and organizations inherit def parameters from taxonomies
        case nested_obj
        when Hostgroup
          :group_parameters
        when Location
          :location_parameters
        when Organization
          :organization_parameters
        else
          :parameters
        end
      end

      def allowed_nested_id
        %w(host_id hostgroup_id domain_id subnet_id operatingsystem_id location_id organization_id)
      end

      def find_parameter
        # nested_obj is required, so no need to check here
        @parameters = nested_obj.send(parameters_method).authorized(current_permission)
        @parameter = @parameters.from_param(params[:id])
        @parameter ||= @parameters.friendly.find(params[:id])
        return @parameter if @parameter.present?
        not_found
      end
    end
  end
end
