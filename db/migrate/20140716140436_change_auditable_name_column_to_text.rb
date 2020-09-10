class ChangeAuditableNameColumnToText < ActiveRecord::Migration[4.2]
  def up
    change_column :audits, :auditable_name, :text
  end

  def down
    change_column :audits, :auditable_name, :string
  end
end
