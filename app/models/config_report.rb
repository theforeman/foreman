class ConfigReport < Report
  class << self
    delegate :model_name, :to => :superclass
  end

  def self.import(report, proxy_id = nil)
    ConfigReportImporter.import(report, proxy_id)
  end

  def summary_status
    return _("Failed")   if error?
    return _("Modified") if changes?
    _("Success")
  end

  # puppet report status table column name
  def self.report_status
    "status"
  end
end
