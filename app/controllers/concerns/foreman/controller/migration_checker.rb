module Foreman::Controller::MigrationChecker
  extend ActiveSupport::Concern

  included do
    before_action :check_pending_migrations
  end

  def self.needs_migration?
    return @needs_migration unless @needs_migration.nil?
    @needs_migration = ActiveRecord::Base.connection.migration_context.needs_migration?
  end

  private

  def check_pending_migrations
    if Foreman::Controller::MigrationChecker.needs_migration?
      raise Foreman::MaintenanceException, _("There are migrations pending in the system.")
    end
  end
end
