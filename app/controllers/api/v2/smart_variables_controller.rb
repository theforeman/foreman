module Api
  module V2
    class SmartVariablesController < V2::BaseController
      include Api::Version2
      include Api::V2::LookupKeysCommonController
      alias_method :resource_scope, :smart_variables_resource_scope

      api :GET, "/smart_variables", N_("List all smart variables")
      api :GET, "/hosts/:host_id/smart_variables", N_("List of smart variables for a specific host")
      api :GET, "/hostgroups/:hostgroup_id/smart_variables", N_("List of smart variables for a specific host group")
      api :GET, "/puppetclasses/:puppetclass_id/smart_variables", N_("List of smart variables for a specific Puppet class")
      param :host_id, :identifier, :required => false
      param :hostgroup_id, :identifier, :required => false
      param :puppetclass_id, :identifier, :required => false
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
      end

      api :GET, "/smart_variables/:id/", N_("Show a smart variable")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :smart_variable do
        param :smart_variable, Hash, :required => true, :action_aware => true do
          param :variable, String, :required => true
          param :puppetclass_id, :number
          param :default_value, String
          param :override_value_order, String
          param :description, String
          param :validator_type, String
          param :validator_rule, String
          param :variable_type, String
          param :merge_overrides, :bool
          param :avoid_duplicates, :bool
        end
      end

      api :POST, "/smart_variables", N_("Create a smart variable")
      param_group :smart_variable, :as => :create

      def create
        @smart_variable   = LookupKey.new(params[:smart_variable]) unless @puppetclass
        @smart_variable ||= @puppetclass.lookup_keys.build(params[:smart_variable])
        @smart_variable.save!
      end

      api :PUT, "/smart_variables/:id", N_("Update a smart variable")
      param :id, :identifier, :required => true
      param_group :smart_variable

      def update
        @smart_variable.update_attributes!(params[:smart_variable])
        render 'api/v2/smart_variables/show'
      end

      api :DELETE, "/smart_variables/:id", N_("Delete a smart variable")
      param :id, :identifier, :required => true

      def destroy
        @smart_variable.destroy
        render 'api/v2/smart_variables/destroy'
      end

      # overwrite Api::BaseController
      def resource_class
        LookupKey
      end

    end
  end
end
