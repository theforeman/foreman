class ReportTemplatesController < TemplatesController
  include Foreman::Controller::Parameters::ReportTemplate
  helper_method :documentation_anchor

  def documentation_anchor
    '4.11ReportTemplates'
  end

  def generate
    # can't user before_action :find_resource since it would override the definition from parent TemplatesController
    find_resource
    @composer = ReportComposer.from_ui_params(params)
  end

  def schedule_report
    # can't user before_action :find_resource since it would override the definition from parent TemplatesController
    find_resource
    @composer = ReportComposer.from_ui_params(params)
    if @composer.valid?
      safe_render(@template, template_input_values: @composer.template_input_values, render_on_error: 'generate')
      if response.status < 400
        headers["Cache-Control"] = "no-cache"
        headers["Content-Disposition"] = %(attachment; filename="#{@template.suggested_report_name}")
      end
      return
    end

    error _('Could not generate the report, check the form for error messages'), :now => true
    render :generate
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
