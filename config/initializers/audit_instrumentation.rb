# Audit logging from fact importer events sent via ActiveSupport::Notifications
module Foreman
  class FactImporterLogSubscriber < ActiveSupport::LogSubscriber
    def logger
      ::Foreman::Logging.logger('audit')
    end

    def filter_facts(event, collection)
      if event.payload[collection]
        event.payload[:facts].select {|k, v| event.payload[collection].include?(k)}.inspect
      else
        {}
      end
    end

    def log_importer(event, action)
      facts = filter_facts(event, action)
      logger.info "[#{event.payload[:host_name]}] #{action} #{event.payload[:count]} (#{event.duration.round(1)}ms)"
      logger.debug facts.inspect unless facts.empty?
    end

    def fact_importer_added(event)
      log_importer(event, :added)
    end

    def fact_importer_updated(event)
      log_importer(event, :updated)
    end

    def fact_importer_deleted(event)
      log_importer(event, :deleted)
    end
  end
end

Foreman::FactImporterLogSubscriber.attach_to :foreman
