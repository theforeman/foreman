module Foreman
  class CustomizedLogSubscriber < ActiveSupport::LogSubscriber
    def params_logger
      ::Foreman::Logging.logger('params')
    end

    # See config/initializers/0_custom_logging.rb for more details
    def start_processing(event)
      return unless logger.info?

      payload = event.payload
      format  = payload[:format]
      format  = format.to_s.upcase if format.is_a?(Symbol)

      info "Processing by #{payload[:controller]}##{payload[:action]} as #{format}"

      params = payload[:params].except(*ActionController::LogSubscriber::INTERNAL_PARAMS)
      params_logger.info "  Parameters: #{params.inspect}" unless params.empty?
    end
  end
end
