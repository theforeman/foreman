module Api
  module V2
    class ReportTemplatesController < V2::BaseController
      include Foreman::Controller::Parameters::ReportTemplate
      include Foreman::Controller::TemplateImport

      wrap_parameters :report_template, :include => report_template_params_filter.accessible_attributes(parameter_filter_context)

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show update destroy clone export generate}

      api :GET, "/report_templates/", N_("List all report templates")
      api :GET, "/locations/:location_id/report_templates/", N_("List all report templates per location")
      api :GET, "/organizations/:organization_id/report_templates/", N_("List all report templates per organization")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(ReportTemplate)

      def index
        @report_templates = resource_scope_for_index
      end

      api :GET, "/report_templates/:id/", N_("Show a report template")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :report_template do
        param :report_template, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :template, String, :required => true
          param :snippet, :bool, :allow_nil => true
          param :audit_comment, String, :allow_nil => true
          param :locked, :bool, :desc => N_("Whether or not the template is locked for editing")
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, "/report_templates/", N_("Create a report template")
      param_group :report_template, :as => :create

      def create
        @report_template = ReportTemplate.new(report_template_params)
        process_response @report_template.save
      end

      api :POST, "/report_templates/import", N_("Import a report template")
      param :report_template, Hash, :required => true, :action_aware => true do
        param :name, String, :required => true, :desc => N_("template name")
        param :template, String, :required => true, :desc => N_("template contents including metadata")
        param_group :taxonomies, ::Api::V2::BaseController
      end
      param_group :template_import_options, ::Api::V2::BaseController

      def import
        @report_template = ReportTemplate.import!(*import_attrs_for(:report_template))
        process_response @report_template
      end

      api :GET, "/report_templates/revision"
      param :version, String, :desc => N_("template version")

      def revision
        audit = Audit.authorized(:view_audit_logs).find(params[:version])
        render :json => audit.revision.template
      end

      api :PUT, "/report_templates/:id/", N_("Update a report template")
      param :id, String, :required => true
      param_group :report_template

      def update
        process_response @report_template.update(report_template_params)
      end

      api :DELETE, "/report_templates/:id/", N_("Delete a report template")
      param :id, String, :required => true

      def destroy
        process_response @report_template.destroy
      end

      def_param_group :report_template_clone do
        param :report_template, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_("template name")
        end
      end

      api :POST, "/report_templates/:id/clone", N_("Clone a template")
      param :id, :identifier, :required => true
      param_group :report_template_clone, :as => :create

      def clone
        @report_template = @report_template.clone
        @report_template.name = params[:report_template][:name]
        process_response @report_template.save
      end

      api :GET, '/report_templates/:id/export', N_('Export a report template to ERB')
      param :id, :identifier, :required => true
      def export
        send_data @report_template.to_erb, :type => 'text/plain', :disposition => 'attachment', :filename => @report_template.filename
      end

      api :GET, "/report_templates/:id/generate/", N_("Generate a report template")
      param :id, :identifier, :required => true

      def generate
        response = @report_template.render(params: params)
        send_data response, :filename => @report_template.suggested_report_name.to_s
      rescue => e
        render_error 'standard_error', :status => :internal_error, :locals => { :exception => e }
      end

      private

      def action_permission
        case params[:action]
          when 'clone', 'import'
            'create'
          when 'export'
            'view'
          when 'generate'
            'generate'
          else
            super
        end
      end
    end
  end
end
