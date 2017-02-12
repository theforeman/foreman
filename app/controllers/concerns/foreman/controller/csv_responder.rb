module Foreman::Controller::CsvResponder
  extend ActiveSupport::Concern

  def csv_response(resources, columns = csv_columns)
    headers["Cache-Control"] = "no-cache"
    headers["Content-Type"] = "text/csv; charset=utf-8"
    headers["Content-Disposition"] = %(attachment; filename="#{controller_name}-#{Date.today}.csv")
    self.response_body = CsvExporter.export(resources, columns)
  end

  private
  def csv_columns
    resource_class.column_names - ['created_at', 'updated_at']
  end
end
