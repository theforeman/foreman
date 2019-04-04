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

  def self.graphql_type(new_graphql_type = nil)
    if new_graphql_type
      @graphql_type = new_graphql_type
    else
      @graphql_type || superclass.try(:graphql_type)
    end
  end
end
