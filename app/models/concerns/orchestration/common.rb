module Orchestration::Common
  def handle_validation_errors
    yield
  rescue Net::Validations::Error => e
    logger.debug "Error occured during validations of #{self.class.name}: #{e.message}"
    nil
  end
end
