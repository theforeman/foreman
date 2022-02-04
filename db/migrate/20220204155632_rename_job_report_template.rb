class RenameJobReportTemplate < ActiveRecord::Migration[5.2]
  TEMPLATE_NAMES = {
    "Job invocation - report template" => "Job - Invocation Report",
  }

  def up
    TEMPLATE_NAMES.each do |from, to|
      token = SecureRandom.base64(5)
      ReportTemplate.unscoped.find_by(name: to)&.update_columns(:name => "#{to} Backup #{token}")
      ReportTemplate.unscoped.find_by(name: from)&.update_columns(:name => to)
    end
  end

  def down
    TEMPLATE_NAMES.each do |from, to|
      ReportTemplate.unscoped.find_by(name: from)&.delete
      ReportTemplate.unscoped.find_by(name: to)&.update_columns(:name => from)
    end
  end
end
