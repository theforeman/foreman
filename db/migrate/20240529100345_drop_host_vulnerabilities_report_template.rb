class DropHostVulnerabilitiesReportTemplate < ActiveRecord::Migration[6.1]
  def up
    scope = ::Template.where(type: 'ReportTemplate', name: 'Host - Vulnerabilities')
    ::TemplateInput.where(template_id: scope).delete_all
    scope.delete_all
  end
end
