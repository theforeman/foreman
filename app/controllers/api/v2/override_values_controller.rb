module Api
  module V2
    class OverrideValuesController < V2::BaseController
      include Api::Version2
      include Api::V2::LookupKeysCommonController
      include Foreman::Controller::Parameters::LookupValue

      before_action :find_override_values
      before_action :find_override_value, :only => [:show, :update, :destroy]
      # override return_if_smart_mismatch in LookupKeysCommonController to add :create
      before_action :return_if_smart_mismatch, :only => [:create, :show, :update, :destroy]
      before_action :return_if_override_mismatch, :only => [:show, :update, :destroy]

      before_action :rename_use_puppet_default, :only => [:create, :update]
      before_action :cast_value, :only => [:create, :update]

      api :GET, "/smart_variables/:smart_variable_id/override_values", N_("List of override values for a specific smart variable")
      api :GET, "/smart_class_parameters/:smart_class_parameter_id/override_values", N_("List of override values for a specific smart class parameter")
      param :smart_variable_id, :identifier, :required => false
      param :smart_class_parameter_id, :identifier, :required => false
      param :show_hidden, :bool, :desc => N_("Display hidden values")
      param_group :pagination, ::Api::V2::BaseController

      def index
      end

      api :GET, "/smart_variables/:smart_variable_id/override_values/:id", N_("Show an override value for a specific smart variable")
      api :GET, "/smart_class_parameters/:smart_class_parameter_id/override_values/:id", N_("Show an override value for a specific smart class parameter")
      param :smart_variable_id, :identifier, :required => false
      param :smart_class_parameter_id, :identifier, :required => false
      param :id, :identifier, :required => true
      param :show_hidden, :bool, :desc => N_("Display hidden values")

      def show
      end

      def_param_group :override_value do
        param :override_value, Hash, :required => true, :action_aware => true do
          param :match, String, :required => true, :desc => N_("Override match")
          param :value, :any_type, :of => LookupKey::KEY_TYPES, :required => false, :desc => N_("Override value, required if omit is false")
          param :use_puppet_default, :bool, :required => false, :desc => N_("Deprecated, please use omit")
          param :omit, :bool, :required => false, :desc => N_("Foreman will not send this parameter in classification output, replaces use_puppet_default")
        end
      end

      api :POST, "/smart_variables/:smart_variable_id/override_values", N_("Create an override value for a specific smart variable")
      api :POST, "/smart_class_parameters/:smart_class_parameter_id/override_values", N_("Create an override value for a specific smart class parameter")
      param :smart_variable_id, :identifier, :required => false
      param :smart_class_parameter_id, :identifier, :required => false
      param_group :override_value, :as => :create

      def create
        @override_value = @smart.lookup_values.create!(lookup_value_params)
        @smart.update_attribute(:override, true)
        process_response @override_value
      end

      api :PUT, "/smart_variables/:smart_variable_id/override_values/:id", N_("Update an override value for a specific smart variable")
      api :PUT, "/smart_class_parameters/:smart_class_parameter_id/override_values/:id", N_("Update an override value for a specific smart class parameter")
      param :smart_variable_id, :identifier, :required => false
      param :smart_class_parameter_id, :identifier, :required => false
      param_group :override_value

      def update
        @override_value.update!(lookup_value_params)
        render 'api/v2/override_values/show'
      end

      api :DELETE, "/smart_variables/:smart_variable_id/override_values/:id", N_("Delete an override value for a specific smart variable")
      api :DELETE, "/smart_class_parameters/:smart_class_parameter_id/override_values/:id", N_("Delete an override value for a specific smart class parameter")
      param :smart_variable_id, :identifier, :required => false
      param :smart_class_parameter_id, :identifier, :required => false
      param :id, :identifier, :required => true

      def destroy
        @override_value.destroy
        render 'api/v2/override_values/show'
      end

      private

      def find_override_values
        if @smart
          @override_values = @smart.lookup_values.paginate(paginate_options)
          @total = @override_values.count
        end
      end

      def find_override_value
        @override_value = LookupValue.find_by_id(params[:id])
        if @smart
          @override_value ||= @smart.lookup_values.friendly.find(params[:id])
        end
      end

      def return_if_override_mismatch
        if (@override_values && @override_value && !@override_values.find_by_id(@override_value.id)) || (@override_values && !@override_value) || !@override_values
          not_found "Override value not found by id '#{params[:id]}'"
        end
      end

      # overwrite Api::BaseController
      def resource_class
        LookupValue
      end

      def rename_use_puppet_default
        return unless params[:override_value]&.key?(:use_puppet_default)

        params[:override_value][:omit] = params[:override_value].delete(:use_puppet_default)
        Foreman::Deprecation.api_deprecation_warning('"use_puppet_default" was renamed to "omit"')
      end
    end
  end
end
