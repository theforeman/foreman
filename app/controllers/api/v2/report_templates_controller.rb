module Api
  module V2
    class ReportTemplatesController < V2::BaseController
      include Foreman::Controller::Parameters::ReportTemplate
      include Foreman::Controller::TemplateImport

      resource_description do
        param :location_id, Integer, :required => false, :desc => N_("Set the current location context for the request")
        param :organization_id, Integer, :required => false, :desc => N_("Set the current organization context for the request")
      end

      wrap_parameters :report_template, :include => report_template_params_filter.accessible_attributes(parameter_filter_context)

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show update destroy clone export generate schedule_report report_data}
      before_action :load_and_authorize_plan, only: 'report_data'

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
          param :description, String
          param :template, String, :required => true
          param :snippet, :bool, :allow_nil => true
          param :audit_comment, String, :allow_nil => true
          param :locked, :bool, :desc => N_("Whether or not the template is locked for editing")
          param :default, :bool, :desc => N_("Whether or not the template is added automatically to new organizations and locations")
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
        @report_template = @report_template.dup
        @report_template.name = params[:report_template][:name]
        process_response @report_template.save
      end

      api :GET, '/report_templates/:id/export', N_('Export a report template to ERB')
      param :id, :identifier, :required => true
      def export
        send_data @report_template.to_erb, :type => 'text/plain', :disposition => 'attachment', :filename => @report_template.filename
      end

      api :POST, "/report_templates/:id/generate/", N_("Generate report from a template")
      param :id, :identifier, :required => true
      param :input_values, Hash, :desc => N_('Hash of input values where key is the name of input, value is the value for this input')
      param :gzip, :bool, desc: N_('Compress the report uzing gzip'), default_value: false
      param :report_format, ReportTemplateFormat.selectable.map(&:id), desc: N_("Report format, defaults to '%s'") % ReportTemplateFormat.default.id

      def generate
        @composer = ReportComposer.from_api_params(params)
        if @composer.valid?
          response = @composer.render(params: params)
          send_data response, type: @composer.mime_type, filename: @composer.report_filename
        else
          @report_template = @composer
          process_resource_error
        end
      rescue => e
        render_error :custom_error, :status => :unprocessable_entity,
                     :locals => { :message => _("Generating Report template failed for: %s." % e.message) }
      end

      api :POST, "/report_templates/:id/schedule_report/", N_("Schedule generating of a report")
      param :id, :identifier, :required => true
      param :input_values, Hash, :desc => N_('Hash of input values where key is the name of input, value is the value for this input')
      param :gzip, :bool, desc: N_('Compress the report using gzip')
      param :mail_to, String, desc: N_("If set, scheduled report will be delivered via e-mail. Use '%s' to separate multiple email addresses.") % ReportComposer::MailToValidator::MAIL_DELIMITER
      param :generate_at, String, desc: N_("UTC time to generate report at")
      param :report_format, ReportTemplateFormat.selectable.map(&:id), desc: N_("Report format, defaults to '%s'") % ReportTemplateFormat.default.id
      returns :code => 200, :desc => "a successful response" do
        property :job_id, String, :desc => "An ID of job, which generates report. To be used with report_data API endpoint for report data retrieval."
        property :data_url, String, :desc => "An url to get resulting report from. This is not available when report is delivered via e-mail."
      end
      example <<-EXAMPLE
      POST /api/report_templates/:id/schedule_report/
      200
      {
        "job_id": UNIQUE-REPORT-GENERATING-JOB-UUID
        "data_url": "/api/v2/report_templates/1/report_data/UNIQUE-REPORT-GENERATING-JOB-UUID"
      }
      EXAMPLE
      description <<-DOC
        The reports are generated asynchronously.
        If mail_to is not given, action returns an url to get resulting report from (see <b>report_data</b>).
      DOC

      def schedule_report
        @composer = ReportComposer.from_api_params(params)
        if @composer.valid?
          job = @composer.schedule_rendering
          response = { job_id: job.provider_job_id }
          response[:data_url] = report_data_api_report_template_path(@report_template, job_id: job.provider_job_id) unless @composer.send_mail?
          render json: response
        else
          @report_template = @composer
          process_resource_error
        end
      rescue => e
        render_error :custom_error, :status => :unprocessable_entity,
                     :locals => { :message => _("Scheduling Report template failed for: %s." % e.message) }
      end

      api :GET, "/report_templates/:id/report_data/:job_id", N_("Downloads a generated report")
      param :id, :identifier, required: true
      param :job_id, String, required: true, desc: N_('ID assigned to generating job by the schedule command')
      description <<-DOC
        Returns the report data as a raw response.
        In case the report hasn't been generated yet, it will return an empty response with http status 204 - NoContent.
      DOC

      def report_data
        if @plan.progress < 1
          head :no_content
        elsif @plan.failure?
          errors = [{ message: _('Generating of report has been canceled') }] if @plan.result == :cancelled
          errors ||= @plan.errors
          render json: { errors: errors }, status: :unprocessable_entity
        else
          data = StoredValue.read(params[:job_id])
          return not_found(_('Report data are not available, it has probably expired.')) unless data
          data = data.to_json if @composer.mime_type == 'application/json'
          send_data data, type: @composer.mime_type, filename: @composer.report_filename
        end
      end

      private

      def action_permission
        case params[:action]
          when 'clone', 'import'
            'create'
          when 'export'
            'view'
          when 'generate', 'schedule_report', 'report_data'
            'generate'
          else
            super
        end
      end

      def parent_permission(child_permission)
        case child_permission.to_s
        when 'generate', 'schedule_report', 'report_data'
          'view'
        else
          super
        end
      end

      def load_and_authorize_plan
        @plan = load_dynflow_plan(params[:job_id])
        return not_found(_('Report not found, please ensure you used the correct job_id')) if @plan.nil?
        return @plan if @plan.progress < 1 || @plan.failure?
        composer_attrs, options = plan_arguments(@plan)
        if User.current.admin? || options['user_id'].to_i == User.current.id
          @composer = ReportComposer.new(composer_attrs)
        else
          deny_access(_('Data are available only for the user who triggered the report and administrators'))
        end
      end

      def load_dynflow_plan(plan_id)
        Rails.application.dynflow.world.persistence.load_execution_plan(plan_id)
      rescue => e
        Foreman::Logging.exception 'Dynflow plan lookup failed', e
        nil
      end

      def plan_arguments(plan)
        plan.actions.first.input['job_data']['arguments']
      end
    end
  end
end
