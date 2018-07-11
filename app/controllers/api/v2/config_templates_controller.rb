module Api
  module V2
    class ConfigTemplatesController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::ProvisioningTemplates
      include Foreman::Controller::Parameters::ProvisioningTemplate

      before_action :deprecated

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show update destroy clone}

      before_action :handle_template_upload, :only => [:create, :update]
      before_action :process_template_kind, :only => [:create, :update]
      before_action :process_operatingsystems, :only => [:create, :update]

      api :GET, "/config_templates/", N_("List provisioning templates")
      api :GET, "/operatingsystems/:operatingsystem_id/config_templates", N_("List provisioning templates per operating system")
      api :GET, "/locations/:location_id/config_templates/", N_("List provisioning templates per location")
      api :GET, "/organizations/:organization_id/config_templates/", N_("List provisioning templates per organization")
      param :operatingsystem_id, String, :desc => N_("ID of operating system")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(ProvisioningTemplate)

      def index
        @config_templates = resource_scope_for_index.includes(:template_kind)
      end

      api :GET, "/config_templates/:id", N_("Show provisioning template details")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :config_template do
        param :config_template, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_("template name")
          param :template, String, :required => true
          param :snippet, :bool, :allow_nil => true
          param :audit_comment, String, :allow_nil => true
          param :template_kind_id, :number, :allow_nil => true, :desc => N_("not relevant for snippet")
          param :template_combinations_attributes, Array,
                :desc => N_("Array of template combinations (hostgroup_id, environment_id)")
          param :operatingsystem_ids, Array, :desc => N_("Array of operating system IDs to associate with the template")
          param :locked, :bool, :desc => N_("Whether or not the template is locked for editing")
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, "/config_templates/", N_("Create a provisioning template")
      param_group :config_template, :as => :create

      def create
        @config_template = ProvisioningTemplate.new(provisioning_template_params)
        process_response @config_template.save
      end

      api :PUT, "/config_templates/:id", N_("Update a provisioning template")
      param :id, :identifier, :required => true
      param_group :config_template

      def update
        process_response @config_template.update(provisioning_template_params)
      end

      api :GET, "/config_templates/revision"
      param :version, String, :desc => N_("template version")

      def revision
        audit = Audit.authorized(:view_audit_logs).find(params[:version])
        render :json => audit.revision.template
      end

      api :DELETE, "/config_templates/:id", N_("Delete a provisioning template")
      param :id, :identifier, :required => true

      def destroy
        process_response @config_template.destroy
      end

      api :POST, "/config_templates/build_pxe_default", N_("Update the default PXE menu on all configured TFTP servers")

      def build_pxe_default
        Foreman::Deprecation.api_deprecation_warning("GET method for build pxe default is deprecated. Please use POST instead") if request.method == "GET"
        status, msg = ProvisioningTemplate.authorized(:deploy_provisioning_templates).build_pxe_default
        render_message(msg, :status => status)
      end

      def_param_group :config_template_clone do
        param :config_template, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_("template name")
        end
      end

      api :POST, "/config_templates/:id/clone", N_("Clone a provision template")
      param :id, :identifier, :required => true
      param_group :config_template_clone, :as => :create

      def clone
        @config_template = @config_template.clone
        load_vars_from_template
        @config_template.name = params[:config_template][:name]
        process_response @config_template.save
      end

      def resource_name(resource = nil)
        if resource.present?
          super
        else
          'config_template'
        end
      end

      private

      def type_name_singular
        @type_name_singular ||= resource_name
      end

      def deprecated
        Foreman::Deprecation.api_deprecation_warning("The resources /config_templates were moved to /provisioning_templates. Please use the new path instead")
      end

      def resource_class
        ProvisioningTemplate
      end

      def process_operatingsystems
        return unless (ct = params[:config_template]) && (operatingsystems = ct.delete(:operatingsystems))
        ct[:operatingsystem_ids] = operatingsystems.collect {|os| os[:id]}
      end

      def allowed_nested_id
        %w(operatingsystem_id location_id organization_id)
      end

      def controller_permission
        @controller_permission ||= resource_class.to_s.underscore.pluralize
      end

      def action_permission
        case params[:action]
          when 'clone'
            'create'
          else
            super
        end
      end
    end
  end
end
