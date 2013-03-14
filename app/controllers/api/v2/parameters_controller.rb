module Api
  module V2
    class ParametersController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => [:show, :update, :destroy]
      before_filter :find_nested_object, :only => [:index, :show, :create, :reset]

      resource_description do
        desc <<-DOC
          These API calls are related to <b>nested parameters for host, domain, hostgroup, operating system</b>. If you are looking for
          <a href="common_parameters.html">global parameters</a>, go to <a href="common_parameters.html">this link</a>.
        DOC
      end

      api :GET, "/host/:host_id/parameters", "List all parameters for host"
      api :GET, "/hostgroup/:hostgroup_id/parameters", "List all parameters for hostgroup"
      api :GET, "/domain/:domain_id/parameters", "List all parameters for domain"
      api :GET, "/operatingsystem/:operatingsystem_id/parameters", "List all parameters for operating system"
      param :host_id, String, :desc => "id of host"
      param :hostgroup_id, String, :desc => "id of hostgroup"
      param :domain_id, String, :desc => "id of domain"
      param :operatingsystem_id, String, :desc => "id of operating system"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @parameters = nested_obj.send(parameters_method).paginate(paginate_options)
      end

      api :GET, "/host/:host_id/parameters/:id", "Show a nested parameter for host"
      api :GET, "/hostgroup/:hostgroup_id/parameters/:id", "Show a nested parameter for hostgroup"
      api :GET, "/domain/:domain_id/parameters/:id", "Show a nested parameter for domain"
      api :GET, "/operatingsystem/:operatingsystem_id/parameters/:id", "Show a nested parameter for operating system"
      param :host_id, String, :desc => "id of host"
      param :hostgroup_id, String, :desc => "id of hostgroup"
      param :domain_id, String, :desc => "id of domain"
      param :operatingsystem_id, String, :desc => "id of operating system"
      param :id, String, :required => true, :desc => "id of parameter"

      def show
      end

      api :POST, "/host/:host_id/parameters/:id", "Create a nested parameter for host"
      api :POST, "/hostgroup/:hostgroup_id/parameters/:id", "Create a nested parameter for hostgroup"
      api :POST, "/domain/:domain_id/parameters/:id", "Create a nested parameter for domain"
      api :POST, "/operatingsystem/:operatingsystem_id/parameters/:id", "Create a nested parameter for operating system"
      param :host_id, String, :desc => "id of host"
      param :hostgroup_id, String, :desc => "id of hostgroup"
      param :domain_id, String, :desc => "id of domain"
      param :operatingsystem_id, String, :desc => "id of operating system"
      param :id, String, :required => true, :desc => "id of parameter"
      param :parameter, Hash, :required => true do
        param :name, String
        param :value, String
      end

      def create
        @parameter = nested_obj.send(parameters_method).new(params[:parameter])
        process_response @parameter.save
      end

      api :PUT, "/host/:host_id/parameters/:id", "Update a nested parameter for host"
      api :PUT, "/hostgroup/:hostgroup_id/parameters/:id", "Update a nested parameter for hostgroup"
      api :PUT, "/domain/:domain_id/parameters/:id", "Update a nested parameter for domain"
      api :PUT, "/operatingsystem/:operatingsystem_id/parameters/:id", "Update a nested parameter for operating system"
      param :host_id, String, :desc => "id of host"
      param :hostgroup_id, String, :desc => "id of hostgroup"
      param :domain_id, String, :desc => "id of domain"
      param :operatingsystem_id, String, :desc => "id of operating system"
      param :id, String, :required => true, :desc => "id of parameter"
      param :parameter, Hash, :required => true do
        param :name, String
        param :value, String
      end

      def update
        process_response @parameter.update_attributes(params[:parameter])
      end

      api :DELETE, "/host/:host_id/parameters/:id", "Delete a nested parameter for host"
      api :DELETE, "/hostgroup/:hostgroup_id/parameters/:id", "Delete a nested parameter for hostgroup"
      api :DELETE, "/domain/:domain_id/parameters/:id", "Delete a nested parameter for domain"
      api :DELETE, "/operatingsystem/:operatingsystem_id/parameters/:id", "Delete a nested parameter for operating system"
      param :host_id, String, :desc => "id of host"
      param :hostgroup_id, String, :desc => "id of hostgroup"
      param :domain_id, String, :desc => "id of domain"
      param :operatingsystem_id, String, :desc => "id of operating system"
      param :id, String, :required => true, :desc => "id of parameter"

      def destroy
        process_response @parameter.destroy
      end

      api :DELETE, "/host/:host_id/parameters", "Delete all nested parameters for host"
      api :DELETE, "/hostgroup/:hostgroup_id/parameters", "Delete all nested parameters for hostgroup"
      api :DELETE, "/domain/:domain_id/parameters", "Delete all nested parameters for domain"
      api :DELETE, "/operatingsystem/:operatingsystem_id/parameters", "Delete all nested parameters for operating system"

      def reset
        @parameter = nested_obj.send(parameters_method)
        process_response @parameter.destroy_all
      end

      private
      attr_reader :nested_obj

      def find_nested_object
        params.keys.each do |param|
          if param =~ /(\w+)_id$/
            resource_identifying_attributes.each do |key|
              find_method = "find_by_#{key}"
              @nested_obj ||= $1.classify.constantize.send(find_method, params[param])
            end
          end
        end
        return nested_obj if nested_obj
        render_error 'not_found', :status => :not_found and return false
      end

      def parameters_method
        # hostgroup.rb has a method def parameters, so I didn't create has_many :parameters like Host, Domain, Os
        nested_obj.is_a?(Hostgroup) ? :group_parameters : :parameters
      end

    end
  end
end
