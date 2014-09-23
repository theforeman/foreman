
module Api
  module V2
    class CommonParametersController < V2::BaseController
      before_filter(:only => %w{show update destroy}) { find_resource('globals') }

      api :GET, "/common_parameters/", N_("List all global parameters.")
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @common_parameters = CommonParameter.
          authorized(:view_globals, CommonParameter).
          search_for(*search_options).
          paginate(paginate_options)
      end

      api :GET, "/common_parameters/:id/", N_("Show a global parameter")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :common_parameter do
        param :common_parameter, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :value, String, :required => true
          param :hidden_value, [true, false]
        end
      end

      api :POST, "/common_parameters/", N_("Create a global parameter")
      param_group :common_parameter, :as => :create

      def create
        @common_parameter = CommonParameter.new(params[:common_parameter])
        process_response @common_parameter.save
      end

      api :PUT, "/common_parameters/:id/", N_("Update a global parameter")
      param :id, :identifier, :required => true
      param_group :common_parameter

      def update
        process_response @common_parameter.update_attributes(params[:common_parameter])
      end

      api :DELETE, "/common_parameters/:id/", N_("Delete a global parameter")
      param :id, :identifier, :required => true

      def destroy
        process_response @common_parameter.destroy
      end

    end
  end
end
