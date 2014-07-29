module Api
  module V2
    class OverrideValuesController < V2::BaseController
      include Api::Version2
      include Api::V2::LookupKeysCommonController

      before_filter :find_override_values
      before_filter :find_override_value, :only => [:show, :update, :destroy]
      # override return_if_smart_mismatch in LookupKeysCommonController to add :index, :create
      before_filter :return_if_smart_mismatch, :only => [:index, :create, :show, :update, :destroy]
      before_filter :return_if_override_mismatch, :only => [:show, :update, :destroy]

      api :GET, "/smart_variables/:smart_variable_id/override_values", N_("List of override values for a specific smart variable")
      api :GET, "/smart_class_parameters/:smart_class_parameter_id/override_values", N_("List of override values for a specific smart class parameter")
      param :smart_variable_id, :identifier, :required => false
      param :smart_class_parameter_id, :identifier, :required => false
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")

      def index
      end

      api :GET, "/smart_variables/:smart_variable_id/override_values/:id", N_("Show an override value for a specific smart variable")
      api :GET, "/smart_class_parameters/:smart_class_parameter_id/override_values/:id", N_("Show an override value for a specific smart class parameter")
      param :smart_variable_id, :identifier, :required => false
      param :smart_class_parameter_id, :identifier, :required => false
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :override_value do
        param :override_value, Hash, :action_aware => true do
          param :match, String
          param :value, String
        end
      end

      api :POST, "/smart_variables/:smart_variable_id/override_values", N_("Create an override value for a specific smart variable")
      api :POST, "/smart_class_parameters/:smart_class_parameter_id/override_values", N_("Create an override value for a specific smart class parameter")
      param :smart_variable_id, :identifier, :required => false
      param_group :override_value, :as => :create

      def create
        @override_value = @smart.lookup_values.create!(params[:override_value])
      end

      api :PUT, "/smart_variables/:smart_variable_id/override_values/:id", N_("Update an override value for a specific smart variable")
      api :PUT, "/smart_class_parameters/:smart_class_parameter_id/override_values/:id", N_("Update an override value for a specific smart class parameter")
      param_group :override_value

      def update
        @override_value.update_attributes!(params[:override_value])
        render 'api/v2/override_values/show'
      end

      api :DELETE, "/smart_variables/:smart_variable_id/override_values/:id", N_("Delete an override value for a specific smart variable")
      api :DELETE, "/smart_class_parameters/:smart_class_parameter_id/override_values/:id", N_("Delete an override value for a specific smart class parameter")
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

    end
  end
end
