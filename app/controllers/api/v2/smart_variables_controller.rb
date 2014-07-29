module Api
  module V2
    class SmartVariablesController < V2::BaseController
      include Api::Version2
      include Api::V2::LookupKeysCommonController
      alias_method :resource_scope, :smart_variables_resource_scope

      api :GET, '/smart_variables', 'List all smart variables'
      api :GET, '/hosts/:host_id/smart_variables', 'List of smart variables for a specific host'
      api :GET, '/hostgroups/:hostgroup_id/smart_variables', 'List of smart variables for a specific hostgroup'
      api :GET, '/puppetclasses/:puppetclass_id/smart_variables', 'List of smart variables for a specific puppetclass'
      param :host_id, :identifier, :required => false
      param :hostgroup_id, :identifier, :required => false
      param :puppetclass_id, :identifier, :required => false
      param :search, String, :desc => 'Filter results'
      param :order, String, :desc => 'sort results'
      param :page, String, :desc => 'paginate results'
      param :per_page, String, :desc => 'number of entries per request'

      def index
      end

      api :GET, '/smart_variables/:id/', 'Show a smart variable.'
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :smart_variable do
        param :variable, String, :required => true,:action_aware => true
        param :puppetclass_id, :number
        param :default_value, String
        param :override_value_order, String
        param :description, String
        param :validator_type, String
        param :validator_rule, String
        param :variable_type, String
      end

      api :POST, '/smart_variables', 'Create a smart variable.'
      param_group :smart_variable, :as => :create

      def create
        @smart_variable   = LookupKey.new(params[:smart_variable]) unless @puppetclass
        @smart_variable ||= @puppetclass.lookup_keys.build(params[:smart_variable])
        @smart_variable.save!
      end

      api :PUT, '/smart_variables/:id', 'Update a smart variable.'
      param :id, :identifier, :required => true
      param_group :smart_variable

      def update
        @smart_variable.update_attributes!(params[:smart_variable])
        render 'api/v2/smart_variables/show'
      end

      api :DELETE, '/smart_variables/:id', 'Delete a smart variable.'
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
