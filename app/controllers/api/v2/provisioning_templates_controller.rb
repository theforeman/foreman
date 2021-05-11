module Api
  module V2
    class ProvisioningTemplatesController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::ProvisioningTemplates
      include Foreman::Controller::Parameters::ProvisioningTemplate
      include Foreman::Controller::TemplateImport

      resource_description do
        param :location_id, Integer, :required => false, :desc => N_("Set the current location context for the request")
        param :organization_id, Integer, :required => false, :desc => N_("Set the current organization context for the request")
      end

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show update destroy clone export}

      before_action :handle_template_upload, :only => [:create, :update]
      before_action :process_template_kind, :only => [:create, :update]
      before_action :process_operatingsystems, :only => [:create, :update]

      api :GET, "/provisioning_templates/", N_("List provisioning templates")
      api :GET, "/operatingsystems/:operatingsystem_id/provisioning_templates", N_("List provisioning templates per operating system")
      api :GET, "/locations/:location_id/provisioning_templates/", N_("List provisioning templates per location")
      api :GET, "/organizations/:organization_id/provisioning_templates/", N_("List provisioning templates per organization")
      param :operatingsystem_id, :number, :desc => N_("ID of operating system")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(ProvisioningTemplate)

      def index
        @provisioning_templates = resource_scope_for_index.includes(:template_kind)
      end

      api :GET, "/provisioning_templates/:id", N_("Show provisioning template details")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :provisioning_template do
        param :provisioning_template, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_("template name")
          param :description, String
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

      api :POST, "/provisioning_templates/", N_("Create a provisioning template")
      param_group :provisioning_template, :as => :create

      def create
        @provisioning_template = ProvisioningTemplate.new(provisioning_template_params)
        process_response @provisioning_template.save
      end

      api :POST, "/provisioning_templates/import", N_("Import a provisioning template")
      param :provisioning_template, Hash, :required => true, :action_aware => true do
        param :name, String, :required => true, :desc => N_("template name")
        param :template, String, :required => true, :desc => N_("template contents including metadata")
        param_group :taxonomies, ::Api::V2::BaseController
      end
      param_group :template_import_options, ::Api::V2::BaseController

      def import
        @provisioning_template = ProvisioningTemplate.import!(*import_attrs_for(:provisioning_template))
        process_response @provisioning_template
      end

      api :PUT, "/provisioning_templates/:id", N_("Update a provisioning template")
      param :id, :identifier, :required => true
      param_group :provisioning_template

      def update
        process_response @provisioning_template.update(provisioning_template_params)
      end

      api :GET, "/provisioning_templates/revision"
      param :version, String, :desc => N_("template version")

      def revision
        audit = Audit.authorized(:view_audit_logs).find(params[:version])
        render :json => audit.revision.template
      end

      api :DELETE, "/provisioning_templates/:id", N_("Delete a provisioning template")
      param :id, :identifier, :required => true

      def destroy
        process_response @provisioning_template.destroy
      end

      api :POST, "/provisioning_templates/build_pxe_default", N_("Update the default PXE menu on all configured TFTP servers")

      def build_pxe_default
        status, msg = ProvisioningTemplate.authorized(:deploy_provisioning_templates).build_pxe_default
        render_message(msg, :status => status)
      end

      def_param_group :provisioning_template_clone do
        param :provisioning_template, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_("template name")
        end
      end

      api :POST, "/provisioning_templates/:id/clone", N_("Clone a provision template")
      param :id, :identifier, :required => true
      param_group :provisioning_template_clone, :as => :create

      def clone
        @provisioning_template = @provisioning_template.clone
        load_vars_from_template
        @provisioning_template.name = params[:provisioning_template][:name]
        process_response @provisioning_template.save
      end

      def resource_name(resource = nil)
        if resource.present?
          super
        else
          'provisioning_template'
        end
      end

      api :GET, '/provisioning_templates/:id/export', N_('Export a provisioning template to ERB')
      param :id, :identifier, :required => true
      def export
        send_data @provisioning_template.to_erb, :type => 'text/plain', :disposition => 'attachment', :filename => @provisioning_template.filename
      end

      private

      def resource_class
        ProvisioningTemplate
      end

      def process_operatingsystems
        return unless (template_params = params[:provisioning_template]) && (operatingsystems = template_params.delete(:operatingsystems))
        template_params[:operatingsystem_ids] = operatingsystems.map { |os| os[:id] }
      end

      def allowed_nested_id
        %w(operatingsystem_id location_id organization_id)
      end

      def action_permission
        case params[:action]
          when 'clone', 'import'
            'create'
          when 'export'
            'view'
          else
            super
        end
      end
    end
  end
end
