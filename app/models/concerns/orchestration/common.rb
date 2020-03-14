module Orchestration::Common
  def handle_validation_errors
    yield
  rescue Net::Validations::Error => e
    logger.debug "Error occured during validations of #{self.class.name}: #{e.message}"
    nil
  end

  def log_orchestration_errors
    logged_errors = []
    logged_errors << errors.full_messages if respond_to?(:errors) && errors.any?
    logged_errors << host.errors.full_messages if respond_to?(:host) && host.respond_to?(:errors) && host.errors.any?
    logger.warn("Not queueing #{self.class.name}: #{logged_errors.to_sentence}") if logged_errors.any?
    false
  end
end
