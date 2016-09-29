class RenameChangesToAuditedChanges < ActiveRecord::Migration
  def up
    rename_column :audits, :changes, :audited_changes
  end

  def down
    rename_column :audits, :audited_changes, :changes
  end
end
