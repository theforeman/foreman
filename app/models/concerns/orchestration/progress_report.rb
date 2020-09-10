module Orchestration::ProgressReport
  extend ActiveSupport::Concern

  def progress_report_id
    @progress_report_id ||= Foreman.uuid
  end

  def progress_report_id=(value)
    @progress_report_id = value
  end
end
