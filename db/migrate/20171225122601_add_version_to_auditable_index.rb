class AddVersionToAuditableIndex < ActiveRecord::Migration[4.2]
  def up
    remove_index :audits, :name => 'auditable_index'
    add_index :audits, [:auditable_id, :auditable_type, :version], :name => 'auditable_index'
  end

  def down
    remove_index :audits, :name => 'auditable_index'
    add_index :audits, [:auditable_id, :auditable_type], :name => 'auditable_index'
  end
end
