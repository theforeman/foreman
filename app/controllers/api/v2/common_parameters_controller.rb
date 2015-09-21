
module Api
  module V2
    class CommonParametersController < V2::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/common_parameters/", N_("List all global parameters.")
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @common_parameters = resource_scope_for_index(:permission => :view_globals)
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
        @common_parameter = CommonParameter.new(foreman_params)
        process_response @common_parameter.save
      end

      api :PUT, "/common_parameters/:id/", N_("Update a global parameter")
      param :id, :identifier, :required => true
      param_group :common_parameter

      def update
        process_response @common_parameter.update_attributes(foreman_params)
      end

      api :DELETE, "/common_parameters/:id/", N_("Delete a global parameter")
      param :id, :identifier, :required => true

      def destroy
        process_response @common_parameter.destroy
      end
    end
  end
end
