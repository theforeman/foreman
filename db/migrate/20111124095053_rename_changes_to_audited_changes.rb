class RenameChangesToAuditedChanges < ActiveRecord::Migration[4.2]
  def up
    rename_column :audits, :changes, :audited_changes
  end

  def down
    rename_column :audits, :audited_changes, :changes
  end
end
