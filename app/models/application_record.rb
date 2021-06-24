require_relative 'concerns/audit_associations'

class ApplicationRecord < ActiveRecord::Base
  extend ApipieDSL::Class

  apipie :prop_group, name: :basic_model_props do
    property :id, Integer, desc: "Numerical ID of the #{@meta[:friendly_name] || @meta[:class_scope]}"
    meta_example = ", e.g. #{@meta[:example]}" if @meta[:example]
    name_desc = @meta[:name_desc] || "Name of the #{@meta[:friendly_name] || @meta[:class_scope]}#{meta_example}"
    property :name, String, desc: name_desc
    property :present?, one_of: [true, false], desc: 'Object presence (always true)'
    property :previous_revision, ApplicationRecord, desc: "Previous revision of the record as tracked in the audit, returns the same object if there is no previous revision"
  end

  class Jail < ::Safemode::Jail
    allow :id, :name, :present?, :previous_revision
  end

  # Overriden by audited for some models
  def previous_revision
    raise "Class #{self.class.name} is not audited"
  end

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
