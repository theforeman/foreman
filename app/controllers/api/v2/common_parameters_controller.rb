
module Api
  module V2
    class CommonParametersController < V2::BaseController
      before_filter(:only => %w{show update destroy}) { find_resource('globals') }

      api :GET, "/common_parameters/", "List all common parameters."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @common_parameters = CommonParameter.
          authorized(:view_globals).
          search_for(*search_options).
          paginate(paginate_options)
      end

      api :GET, "/common_parameters/:id/", "Show a common parameter."
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :common_parameter do
        param :common_parameter, Hash, :action_aware => true do
          param :name, String, :required => true
          param :value, String, :required => true
        end
      end

      api :POST, "/common_parameters/", "Create a common_parameter"
      param_group :common_parameter, :as => :create

      def create
        @common_parameter = CommonParameter.new(params[:common_parameter])
        process_response @common_parameter.save
      end

      api :PUT, "/common_parameters/:id/", "Update a common_parameter"
      param :id, :identifier, :required => true
      param_group :common_parameter

      def update
        process_response @common_parameter.update_attributes(params[:common_parameter])
      end

      api :DELETE, "/common_parameters/:id/", "Delete a common_parameter"
      param :id, :identifier, :required => true

      def destroy
        process_response @common_parameter.destroy
      end

    end
  end
end
