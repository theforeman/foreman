class MigrateOvirtResources < ActiveRecord::Migration[7.0]
  def up
    ComputeResourceCleaner.new(klass: 'Foreman::Model::Ovirt').run!
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot restore migrated Ovirt data."
  end
end
