class ChangeAuditableNameColumnToText < ActiveRecord::Migration
  def up
    change_column :audits, :auditable_name, :text
  end

  def down
    change_column :audits, :auditable_name, :string
  end
end
