module Api
  module V2
    class ParametersController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => [:show, :update, :destroy]
      before_filter :find_nested_object, :only => [:index, :show, :create]

      resource_description do
        desc <<-DOC
          These API calls are related to <b>nested parameters for host, domain, hostgroup, operating system</b>. If you are looking for
          <a href="common_parameters.html">global parameters</a>, go to <a href="common_parameters.html">this link</a>.
        DOC
      end

      api :GET, "/references/:id/parameters/", "List all parameters for host, domain, hostgroup, or operating system"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        if @nested_obj.class.name == 'Hostgroup'
          # hostgroup.rb has a method def parameters, so I didn't create has_many :parameters like Host, Domain, Os
          @parameters = @nested_obj.group_parameters.paginate(paginate_options)
        else
          @parameters = @nested_obj.parameters.paginate(paginate_options)
        end
      end

      api :GET, "/references/:reference_id/parameters/:id/", "Show a nested parameter for host, domain, hostgroup, or operating system"
      param :reference_id, String, :required => true, :desc => "id of nested reference object (:i.e. host, domain, hostgroup, or operating system) results"
      param :id, String, :required => true, :desc => "id of parameter"

      def show
      end

      api :POST, "/references/:reference_id/parameters", "Create a nested parameter for host, domain, hostgroup, or operating system"
      param :reference_id, String, :required => true, :desc => "id of nested reference object (:i.e. host, domain, hostgroup, or operating system) results"
      param :id, String, :required => true, :desc => "id of parameter"
      param :parameter, Hash, :required => true do
        param :name, String
        param :value, String
      end

      def create
        sti_type = @nested_obj.class.name
        sti_type = "Os" if @nested_obj.class.name == "Operatingsystem"
        sti_type = "Group" if @nested_obj.class.name == "Hostgroup"
        # creating the parameter thorough the assocation @nested_obj.parameters.new did not update the type field
        # so the parameter is corrected directly using the STI model
        @parameter = "#{sti_type}Parameter".constantize.new(params[:parameter].merge(:reference_id => @nested_obj.id))
        process_response @parameter.save
      end

      api :PUT, "/references/:reference_id/parameters/:id/", "Update a nested parameter for host, domain, hostgroup, or operating system"
      param :reference_id, String, :required => true, :desc => "id of nested reference object (:i.e. host, domain, hostgroup, or operating system) results"
      param :id, String, :required => true, :desc => "id of parameter"
      param :parameter, Hash, :required => true do
        param :name, String
        param :value, String
      end

      def update
        process_response @parameter.update_attributes(params[:parameter])
      end

      api :DELETE, "/references/:id/parameters/:id/", "Delete a nested parameter for host, domain, hostgroup, or operating system."
      param :reference_id, String, :required => true, :desc => "id of nested reference object (:i.e. host, domain, hostgroup, or operating system) results"
      param :id, String, :required => true, :desc => "id of parameter"

      def destroy
        process_response @parameter.destroy
      end

      private

      def find_nested_object
        params.keys.each do |param|
          if param =~ /(\w+)_id$/
            resource_identifying_attributes.each do |key|
              find_method = "find_by_#{key}"
              @nested_obj ||= $1.classify.constantize.send(find_method, params[param])
            end
          end
        end
        return @nested_obj if @nested_obj
        render_error 'not_found', :status => :not_found and return false
      end

    end
  end
end
