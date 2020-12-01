class RefreshTemplatesRenderingStatusesJob < ApplicationJob
  around_perform do |job, block|
    block.call

    self.class.queue
  rescue StandardError => e
    Foreman::Logging.logger('background').error("#{self.class} error: #{e} \n#{e.backtrace.join("\n")}")

    self.class.queue
  end

  def self.queue
    set(wait: wait_time).perform_later
  end

  def self.wait_time
    Setting[:templates_rendering_status_refresh_interval].minutes
  end

  queue_as :refresh_templates_rendering_statuses

  def perform
    User.as_anonymous_admin do
      Host::Managed.where(managed: true).where(id: HostStatus::TemplatesRenderingStatus.pending.select(:host_id)).map do |host|
        Foreman::Logging.logger('background').info("#{host} - Refreshing templates rendering status")
        host.refresh_statuses([HostStatus::TemplatesRenderingStatus])
        Foreman::Logging.logger('background').info("#{host} - Successfully refreshed templates rendering status")
      rescue StandardError => e
        Foreman::Logging.logger('background').error("#{host} - Error while refreshing templates rendering status: #{e}\n#{e.backtrace.join("\n")}")
        nil
      end
    end
  end
end
