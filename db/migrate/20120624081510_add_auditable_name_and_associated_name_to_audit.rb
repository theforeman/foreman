class AddAuditableNameAndAssociatedNameToAudit < ActiveRecord::Migration[4.2]
  def up
    add_column :audits, :auditable_name, :string, :limit => 255 unless column_exists? :audits, :auditable_name
    add_column :audits, :associated_name, :string, :limit => 255 unless column_exists? :audits, :associated_name
    add_index :audits, :id unless index_exists? :audits, :id
  end

  def down
    remove_index :audits, :id               if  index_exists?  :audits, :id
    remove_column :audits, :associated_name if  column_exists? :audits, :associated_name
    remove_column :audits, :auditable_name  if  column_exists? :audits, :auditable_name
  end
end
