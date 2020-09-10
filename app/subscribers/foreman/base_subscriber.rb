module Foreman
  class BaseSubscriber
    def self.call(*args)
      event = ActiveSupport::Notifications::Event.new(*args)
      Rails.logger.info("#{name}: #{event.name} event received")
      new.call(event)
    end

    def call(event)
      raise NotImplementedError
    end
  end
end
