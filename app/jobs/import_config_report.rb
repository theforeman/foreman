class ImportConfigReport < ApplicationJob
  def perform(config_report, proxy)
    ConfigReport.import(config_report, proxy)
  end

  rescue_from ::Foreman::Exception do |e|
    logger.warn("Error importing report #{e} - #{self.job_id}")
  end
end
