class MigrateOvirtResources < ActiveRecord::Migration[7.0]
  def up
    unless plugin_present?('foreman_ovirt')
      ComputeResourceCleaner.new(klass: 'Foreman::Model::Ovirt').run!
    end
  end

  def down
    unless plugin_present?('foreman_ovirt')
      raise ActiveRecord::IrreversibleMigration, "Cannot restore migrated Ovirt data."
    end
  end

  private

  def plugin_present?(name)
    Foreman::Plugin.find(name).present?
  end
end
