module Api
  module V1
    class CommonParametersController < V1::BaseController
      include Foreman::Controller::Parameters::Parameter

      before_action :find_resource, :only => %w{show update destroy}
      before_filter :rename_common_parameters, :only => %w{update create}

      api :GET, "/common_parameters/", "List all common parameters."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @common_parameters = resource_class.
          authorized(:view_globals, GlobalLookupKey).
          search_for(*search_options).
          paginate(paginate_options)
      end

      api :GET, "/common_parameters/:id/", "Show a common parameter."
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/common_parameters/", "Create a common_parameter"
      param :common_parameter, Hash, :required => true do
        param :name, String, :required => true
        param :value, String, :required => true
        param :hidden_value, [true, false]
      end

      def create
        @common_parameter = GlobalLookupKey.new(parameter_params.merge(:should_be_global => true))
        process_response @common_parameter.save
      end

      api :PUT, "/common_parameters/:id/", "Update a common_parameter"
      param :id, :identifier, :required => true
      param :common_parameter, Hash, :required => true do
        param :name, String
        param :value, String
        param :hidden_value, [true, false]
      end

      def update
        process_response @common_parameter.update_attributes(parameter_params)
      end

      api :DELETE, "/common_parameters/:id/", "Delete a common_parameter"
      param :id, :identifier, :required => true

      def destroy
        process_response @common_parameter.destroy
      end

      def resource_class
        GlobalLookupKey.where(:should_be_global => true)
      end

      def rename_common_parameters
        if parameter_params
          parameter_params[:key] = parameter_params.delete(:name) if parameter_params[:name].present?
          parameter_params[:default_value] =parameter_params.delete(:value) if parameter_params[:value].present?
        end
      end
    end
  end
end
