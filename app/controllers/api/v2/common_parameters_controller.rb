module Api
  module V2
    class CommonParametersController < V2::BaseController
      include Foreman::Controller::Parameters::Parameter

      before_action :find_resource, :only => %w{show update destroy}
      before_filter :rename_common_parameters, :only => %w{update create}

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
          param :name, String, :required => true, :desc => N_("Name of parameter")
          param :value, String, :desc => N_("Default value of parameter")
          param :default_value, String, :desc => N_("Default value of parameter")
          param :hidden_value, :bool, :desc => N_("When enabled the parameter is hidden in the UI")
          param :should_be_global, :bool, :desc => N_("When enabled the parameter is hidden in the UI")
          param :override_value_order, String, :desc => N_("The order in which values are resolved")
          param :description, String, :desc => N_("Description of variable")
          param :validator_type, LookupKey::VALIDATOR_TYPES, :desc => N_("Types of validation values")
          param :validator_rule, String, :desc => N_("Used to enforce certain values for the parameter values")
          param :variable_type, LookupKey::KEY_TYPES, :desc => N_("Types of variable values")
          param :merge_overrides, :bool, :desc => N_("Merge all matching values (only array/hash type)")
          param :merge_default, :bool, :desc => N_("Include default value when merging all matching values")
          param :avoid_duplicates, :bool, :desc => N_("Remove duplicate values (only array type)")
        end
      end

      api :POST, "/common_parameters/", N_("Create a global parameter")
      param_group :common_parameter, :as => :create

      def create
        value = parameter_params().delete(:value)
        parameter_params()[:default_value] = value if value.present?
        @common_parameter = GlobalLookupKey.new(parameter_params())
        process_response @common_parameter.save
      end

      api :PUT, "/common_parameters/:id/", N_("Update a global parameter")
      param :id, :identifier, :required => true
      param_group :common_parameter

      def update
        value = parameter_params().delete(:value)
        parameter_params()[:default_value] = value if value.present?
        process_response @common_parameter.update_attributes(parameter_params())
      end

      api :DELETE, "/common_parameters/:id/", N_("Delete a global parameter")
      param :id, :identifier, :required => true

      def destroy
        process_response @common_parameter.destroy
      end

      def resource_class
        GlobalLookupKey.all
      end

      def rename_common_parameters
        if parameter_params
          parameter_params[:key] = parameter_params.delete(:name) if parameter_params[:name].present?
        end
      end
    end
  end
end
