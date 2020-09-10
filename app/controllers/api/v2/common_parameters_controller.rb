module Api
  module V2
    class CommonParametersController < V2::BaseController
      include Foreman::Controller::Parameters::Parameter

      before_action :find_resource, :only => %w{show update destroy}

      api :GET, "/common_parameters/", N_("List all global parameters")
      param :show_hidden, :bool, :desc => N_("Display hidden values")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Parameter)

      def index
        @common_parameters = resource_scope_for_index(:permission => :view_params)
      end

      api :GET, "/common_parameters/:id/", N_("Show a global parameter")
      param :show_hidden, :bool, :desc => N_("Display hidden values")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :common_parameter do
        param :common_parameter, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :value, String, :required => true
          param :parameter_type, Parameter::KEY_TYPES, :desc => N_("Type of value"), :required => true
          param :hidden_value, [true, false]
        end
      end

      api :POST, "/common_parameters/", N_("Create a global parameter")
      param_group :common_parameter, :as => :create

      def create
        @common_parameter = CommonParameter.new(parameter_params(::CommonParameter))
        process_response @common_parameter.save
      end

      api :PUT, "/common_parameters/:id/", N_("Update a global parameter")
      param :id, :identifier, :required => true
      param_group :common_parameter

      def update
        process_response @common_parameter.update(parameter_params(::CommonParameter))
      end

      api :DELETE, "/common_parameters/:id/", N_("Delete a global parameter")
      param :id, :identifier, :required => true

      def destroy
        process_response @common_parameter.destroy
      end

      private

      def controller_permission
        'params'
      end

      def resource_scope(*args, &block)
        super.where(:type => 'CommonParameter')
      end

      def resource_class
        Parameter
      end
    end
  end
end
