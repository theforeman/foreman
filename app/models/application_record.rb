require_relative 'concerns/audit_associations'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  extend AuditAssociations::AssociationsDefinitions

  # Rails use Notifications for own sql logging so we can override sql logger for orchestration
  def self.logger
    Foreman::Logging.logger('app')
  end

  def logger
    self.class.logger
  end
end
