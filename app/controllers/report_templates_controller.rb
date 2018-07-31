class ReportTemplatesController < TemplatesController
  include Foreman::Controller::Parameters::ReportTemplate
  helper_method :documentation_anchor

  def documentation_anchor
    '4.11ReportTemplates'
  end

  def generate
    find_resource
    headers["Cache-Control"] = "no-cache"
    headers["Content-Disposition"] = %(attachment; filename="#{@template.suggested_report_name}")
    safe_render(@template)
  end

  private

  def action_permission
    case params[:action]
      when 'generate'
        'generate'
      else
        super
    end
  end
end
