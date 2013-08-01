module Api
  module V2
    class LookupKeysController < V2::BaseController
      include Api::Version2

      before_filter :find_resource, :only => [:show, :update, :destroy]
      before_filter :setup_search_options, :only => :index
      before_filter :find_nested_object, :only => [:host_or_hostgroup_smart_parameters,
                                                   :host_or_hostgroup_smart_class_parameters,
                                                   :puppet_smart_parameters]
      before_filter :find_environment, :only => :puppet_smart_class_parameters
      before_filter :find_puppetclass, :only => :puppet_smart_class_parameters


      api :GET, "/hosts/:host_id/smart_parameters", "List of smart parameters for a specific host"
      api :GET, "/hostgroups/:hostgroup_id/smart_parameters", "List of smart parameters for a specific hostgroup"
      param :host_id, :identifier, :required => false
      param :hostgroup_id, :identifier, :required => false
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def host_or_hostgroup_smart_parameters
        puppetclass_ids = nested_obj.all_puppetclasses.map(&:id)
        @lookup_keys = LookupKey.global_parameters_for_class(puppetclass_ids).paginate(paginate_options)
        render :index
      end

      api :GET, "/hosts/:host_id/smart_class_parameters", "List of smart class parameters for a specific host"
      api :GET, "/hostgroups/:hostgroup_id/smart_class_parameters", "List of smart class parameters for a specific hostgroup"
      param :host_id, :identifier, :required => false
      param :hostgroup_id, :identifier, :required => false
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def host_or_hostgroup_smart_class_parameters
        puppetclass_ids = nested_obj.all_puppetclasses.map(&:id)
        environment_id = nested_obj.environment_id
        @lookup_keys = LookupKey.parameters_for_class(puppetclass_ids, environment_id).paginate(paginate_options)
        render :index
      end

      api :GET, "/puppetclasses/:puppetclass_id/smart_parameters", "List of smart parameters for a specific puppetclass"
      param :puppetclass_id, :identifier, :required => true
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def puppet_smart_parameters
        @lookup_keys = LookupKey.global_parameters_for_class(nested_obj.id).
                          search_for(*search_options).paginate(paginate_options)
        render :index
      end

      api :GET, "/puppetclasses/:puppetclass_id/environments/:environment_id/smart_class_parameters", "List of smart class parameters for a specific puppetclass and environment"
      param :puppetclass_id, :identifier, :required => true
      param :environment_id, :identifier, :required => true
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def puppet_smart_class_parameters
        @lookup_keys = LookupKey.smart_class_parameters_for_class(@puppetclass.id, @environment.id).
                          search_for(*search_options).paginate(paginate_options)
        render :index
      end

      ## Same 7 restful actions as in V1

      api :GET, "/smart_variables", "List all smart variables (smart parameters and smart class parameters)."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @lookup_keys = LookupKey.search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/smart_variables/:id/", "Show a smart variable (smart parameter or smart class parameter)."
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/smart_variables", "Create a smart variable."
      param :lookup_key, Hash, :required => true do
        param :key, String, :required => true
        param :puppetclass_id, :number
        param :default_value, String
        param :path, String
        param :description, String
        param :validator_type, String
        param :validator_rule, String
        param :is_param, :bool
        param :key_type, String
        param :override, :bool
        param :required, :bool
      end

      def create
        @lookup_key = LookupKey.new(params[:lookup_key])
        process_response @lookup_key.save
      end

      api :PUT, "/smart_variables/:id", "Update a smart variable."
      param :id, :identifier, :required => true
      param :lookup_key, Hash, :required => true do
        param :key, String, :required => true
        param :puppetclass_id, :number
        param :default_value, String
        param :path, String
        param :description, String
        param :validator_type, String
        param :validator_rule, String
        param :is_param, :bool
        param :key_type, String
        param :override, :bool
        param :required, :bool
      end

      def update
        process_response @lookup_key.update_attributes(params[:lookup_key])
      end

      api :DELETE, "/smart_variables/:id", "Delete a smart variable."
      param :id, :identifier, :required => true

      def destroy
        process_response @lookup_key.destroy
      end

      private

      def find_puppetclass
        if params[:puppetclass_id]
          resource_identifying_attributes.each do |key|
            find_method = "find_by_#{key}"
            @puppetclass ||= Puppetclass.send(find_method, params[:puppetclass_id])
          end
        end
        return @puppetclass if @puppetclass
        render_error 'not_found', :status => :not_found and return false
      end

      def find_environment
        if params[:environment_id]
          resource_identifying_attributes.each do |key|
            find_method = "find_by_#{key}"
            @environment ||= Environment.send(find_method, params[:environment_id])
          end
        end
        return @environment if @environment
        render_error 'not_found', :status => :not_found and return false
      end

    end
  end
end
