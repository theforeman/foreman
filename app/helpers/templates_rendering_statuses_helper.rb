module TemplatesRenderingStatusesHelper
  def to_label(status)
    case status
      when HostStatus::TemplatesRenderingStatus::OK
        HostStatus::TemplatesRenderingStatus::OK_LABEL
      when HostStatus::TemplatesRenderingStatus::SAFEMODE_ERRORS
        HostStatus::TemplatesRenderingStatus::SAFEMODE_ERRORS_LABEL
      when HostStatus::TemplatesRenderingStatus::UNSAFEMODE_ERRORS
        HostStatus::TemplatesRenderingStatus::UNSAFEMODE_ERRORS_LABEL
      when HostStatus::TemplatesRenderingStatus::MISSING_TEMPLATE_ERROR
        HostStatus::TemplatesRenderingStatus::MISSING_TEMPLATE_ERROR_LABEL
      else
        HostStatus::TemplatesRenderingStatus::PENDING_LABEL
    end
  end
end
