class ReportTemplatesController < TemplatesController
  include Foreman::Controller::Parameters::ReportTemplate
  helper_method :documentation_anchor

  # can't use before_action :find_resource since it would override the definition from parent TemplatesController
  alias_method :find_report_resource, :find_resource
  before_action :find_report_resource, only: [:generate, :schedule_report, :report_data]

  def documentation_anchor
    '4.11ReportTemplates'
  end

  def generate
    @composer = ReportComposer.from_ui_params(params)
  end

  def schedule_report
    @composer = ReportComposer.from_ui_params(params)
    if @composer.valid?
      job = TemplateRenderJob.perform_later(@composer.to_param)
      render json: { data_url: report_data_api_report_template_path(@template, job_id: job.provider_job_id) }
    else
      error _('Could not generate the report, check the form for error messages')
      redirect_to templates_generate_report_template_path(@template, report_template_report: @composer)
    end
  end

  private

  def action_permission
    case params[:action]
      when 'generate', 'schedule_report'
        'generate'
      else
        super
    end
  end
end
