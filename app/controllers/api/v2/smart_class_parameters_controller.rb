module Api
  module V2
    class SmartClassParametersController < V2::BaseController
      include Api::Version2
      include Api::V2::LookupKeysCommonController
      alias_method :resource_scope, :smart_class_parameters_resource_scope

      api :GET, "/smart_class_parameters", N_("List all smart class parameters")
      api :GET, "/hosts/:host_id/smart_class_parameters", N_("List of smart class parameters for a specific host")
      api :GET, "/hostgroups/:hostgroup_id/smart_class_parameters", N_("List of smart class parameters for a specific host group")
      api :GET, "/puppetclasses/:puppetclass_id/smart_class_parameters", N_("List of smart class parameters for a specific Puppet class")
      api :GET, "/environments/:environment_id/smart_class_parameters", N_("List of smart class parameters for a specific environment")
      api :GET, "/environments/:environment_id/puppetclasses/:puppetclass_id/smart_class_parameters", N_("List of smart class parameters for a specific environment/Puppet class combination")
      param :host_id, :identifier, :required => false
      param :hostgroup_id, :identifier, :required => false
      param :puppetclass_id, :identifier, :required => false
      param :environment_id, :identifier, :required => false
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
      end

      # no create action for API
      # smart class parameters are imported by PuppetClassImporter

      api :GET, "/smart_class_parameters/:id/", N_("Show a smart class parameter")
      param :id, :identifier, :required => true

      def show
      end

      api :PUT, "/smart_class_parameters/:id", N_("Update a smart class parameter")
      param :id, :identifier, :required => true
      param :smart_class_parameter, Hash, :required => true do
        # can't update parameter/key name for :parameter, String, :required => true
        param :override, :bool, :desc => N_("Whether the smart class parameter value is managed by Foreman")
        param :description, String, :desc => N_("Description of smart class")
        param :default_value, String, :desc => N_("Value to use when there is no match")
        param :use_puppet_default, :bool, :desc => N_("Do not send this parameter via the ENC. Puppet will use the value defined in the Puppet manifest for this parameter")
        param :path, String, :desc => N_("The order in which values are resolved")
        param :validator_type, LookupKey::VALIDATOR_TYPES, :desc => N_("Types of validation values")
        param :validator_rule, String, :desc => N_("Used to enforce certain values for the parameter values")
        param :override_value_order, String, :desc => N_("The order in which values are resolved")
        param :parameter_type, LookupKey::KEY_TYPES, :desc => N_("Types of variable values")
        param :required, :bool, :desc => N_("If true, will raise an error if there is no default value and no matcher provide a value")
        param :merge_overrides, :bool, :desc => N_("Merge all matching values (only array/hash type)")
        param :avoid_duplicates, :bool, :desc => N_("Remove duplicate values (only array type)")
      end

      def update
        #Note:  User must manually set :override => true. It is not automatically updated if optional input validator fields are updated.
        @smart_class_parameter.update_attributes!(params[:smart_class_parameter])
        render 'api/v2/smart_class_parameters/show'
      end

      def destroy
        @smart_class_parameter.destroy
        render 'api/v2/smart_class_parameters/destroy'
      end

      # overwrite Api::BaseController
      def resource_class
        LookupKey
      end
    end
  end
end
