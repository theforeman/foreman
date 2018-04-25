require_relative 'concerns/audit_associations'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  extend AuditAssociations::AssociationsDefinitions

  # Rails use Notifications for own sql logging so we can override sql logger for orchestration
  def logger
    Foreman::Logging.logger('app')
  end
end
