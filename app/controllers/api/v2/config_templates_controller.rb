module Api
  module V2
    class ConfigTemplatesController < V2::BaseController
      include Api::Version2
      include Api::TaxonomyScope
      include Foreman::Renderer
      include Foreman::Controller::ConfigTemplates

      before_filter :find_optional_nested_object
      before_filter :find_resource, :only => %w{show update destroy clone}

      before_filter :handle_template_upload, :only => [:create, :update]
      before_filter :process_template_kind, :only => [:create, :update]
      before_filter :process_operatingsystems, :only => [:create, :update]

      api :GET, "/config_templates/", N_("List provisioning templates")
      api :GET, "/operatingsystem/:operatingsystem_id/config_templates", N_("List provisioning templates per operating system")
      api :GET, "/locations/:location_id/config_templates/", N_("List provisioning templates per location")
      api :GET, "/organizations/:organization_id/config_templates/", N_("List provisioning templates per organization")
      param :operatingsystem_id, String, :desc => N_("ID of operating system")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @config_templates = resource_scope_for_index(:permission => :view_templates).includes(:template_kind)
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
        @config_template = ConfigTemplate.new(params[:config_template])
        process_response @config_template.save
      end

      api :PUT, "/config_templates/:id", N_("Update a provisioning template")
      param :id, :identifier, :required => true
      param_group :config_template

      def update
        process_response @config_template.update_attributes(params[:config_template])
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

      api :GET, "/config_templates/build_pxe_default", N_("Update the default PXE menu on all configured TFTP servers")

      def build_pxe_default
        status, msg = ConfigTemplate.authorized(:deploy_templates).build_pxe_default(self)
        render :json => msg, :status => status
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
        load_vars_from_config_template
        @config_template.name = params[:config_template][:name]
        process_response @config_template.save
      end

      private

      def process_operatingsystems
        return unless (ct = params[:config_template]) and (operatingsystems = ct.delete(:operatingsystems))
        ct[:operatingsystem_ids] = operatingsystems.collect {|os| os[:id]}
      end

      def allowed_nested_id
        %w(operatingsystem_id location_id organization_id)
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
