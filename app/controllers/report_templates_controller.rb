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
      job = @composer.schedule_rendering
      if @composer.send_mail?
        if @composer.generate_at
          success _('Report is going to be rendered at %s and it will be delivered via e-mail once ready.') % l(@composer.generate_at)
        else
          success _('Report is being rendered, it will be delivered via e-mail.')
        end
        redirect_to report_templates_path
      else
        redirect_to report_data_report_template_path(@template, job_id: job.provider_job_id)
      end
    else
      error _('Could not generate the report, check the form for error messages'), now: true
      render 'generate'
    end
  end

  def report_data
    @data_url = report_data_api_report_template_path(@template, job_id: params[:job_id])
  end

  private

  def action_permission
    case params[:action]
      when 'generate', 'schedule_report', 'report_data'
        'generate'
      else
        super
    end
  end
end
