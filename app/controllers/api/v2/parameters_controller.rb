module Api
  module V2
    class ParametersController < V2::BaseController

      before_filter :find_reference
      before_filter :find_parameter_by_reference, :only => %w{show update destroy}

      api :GET, "/references/:id/parameters/", "List all parameters for reference (host, domain, hostgroup, operating system)."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        if reference_name == 'hostgroup'
          # hostgroup.rb has a method def parameters, so I didn't create has_many :parameters like Host, Domain, Os
          @parameters = @reference.group_parameters.paginate(paginate_options)
        else
          @parameters = @reference.parameters.paginate(paginate_options)
        end
      end

      api :GET, "/references/:id/parameters/:id/", "Show a parameter."
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/references/:id/parameters/", "Create a parameter"
      param :parameter, Hash, :required => true do
        param :name, String, :required => true
        param :value, String, :required => true
      end

      def create
        @parameter = HostParameter.new(params[:parameter])
        process_response @parameter.save
      end

      api :PUT, "/references/:id/parameters/:id/", "Update a parameter"
      param :id, :identifier, :required => true
      param :parameter, Hash, :required => true do
        param :name, String
        param :value, String
      end

      def update
        process_response @parameter.update_attributes(params[:parameter])
      end

      api :DELETE, "/references/:id/parameters/:id/", "Delete a parameter"
      param :id, :identifier, :required => true

      def destroy
        process_response @parameter.destroy
      end


      private

      def reference_name
        return "host" if params[:host_id].present?
        return "domain" if params[:domain_id].present?
        return "operatingsystem" if params[:operatingsystem_id].present?
        return "hostgroup" if params[:hostgroup_id].present?
      end

      def reference_class
        @reference_class ||= reference_name.camelize.constantize
      end


      def find_reference
        reference = resource_identifying_attributes.find do |key|
          next if key=='id' and params["#{reference_name}_id".to_sym].to_i == 0
          method = "find_by_#{key}"
          reference_class.respond_to?(method) and
            (reference = reference_class.send method, params["#{reference_name}_id".to_sym]) and
            break reference
        end

        if reference
           instance_variable_set(:"@#{reference_name}", reference)
           instance_variable_set(:"@reference", reference)
           return
        else
          render_error 'not_found', :status => :not_found and return false
        end
      end

      def find_parameter_by_reference
        resource = resource_identifying_attributes.find do |key|
          next if key=='id' and params[:id].to_i == 0
          method = "find_by_#{key}"
          resource_class.respond_to?(method) and
            (resource = @reference.parameters.send method, params[:id]) and
            break resource
        end

        if resource
          return instance_variable_set(:"@#{resource_name}", resource)
        else
          render_error 'not_found', :status => :not_found and return false
        end
      end

    end
  end
end