module Api
  module V2
    class SmartClassParametersController < V2::BaseController
      include Api::Version2
      include Api::V2::LookupKeysCommonController
      alias_method :resource_scope, :smart_class_parameters_resource_scope

      api :GET, '/smart_class_parameters', 'List all smart class parameters'
      api :GET, '/hosts/:host_id/smart_class_parameters', 'List of smart class parameters for a specific host'
      api :GET, '/hostgroups/:hostgroup_id/smart_class_parameters', 'List of smart class parameters for a specific hostgroup'
      api :GET, '/puppetclasses/:puppetclass_id/smart_class_parameters', 'List of smart class parameters for a specific puppetclass'
      api :GET, '/environments/:environment_id/smart_class_parameters', 'List of smart class parameters for a specific environment'
      api :GET, '/environments/:environment_id/puppetclasses/:puppetclass_id/smart_class_parameters', 'List of smart class parameters for a specific environment/puppetclass combination'
      param :host_id, :identifier, :required => false
      param :hostgroup_id, :identifier, :required => false
      param :puppetclass_id, :identifier, :required => false
      param :environment_id, :identifier, :required => false
      param :search, String, :desc => 'Filter results'
      param :order, String, :desc => 'sort results'
      param :page, String, :desc => 'paginate results'
      param :per_page, String, :desc => 'number of entries per request'

      def index
      end

      # no create action for API
      # smart class parameters are imported by PuppetClassImporter

      api :GET, '/smart_class_parameters/:id/', 'Show a smart class parameter.'
      param :id, :identifier, :required => true

      def show
      end

      api :PUT, '/smart_class_parameters/:id', 'Update a smart class parameter.'
      param :id, :identifier, :required => true
      param :smart_class_parameter, Hash, :required => true do
        # can't update parameter/key name for :parameter, String, :required => true
        param :override, :bool
        param :description, String
        param :default_value, String
        param :path, String
        param :validator_type, String
        param :validator_rule, String
        param :override_value_order, String
        param :parameter_type, String
        param :required, :bool
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
