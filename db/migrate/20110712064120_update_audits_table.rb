class UpdateAuditsTable < ActiveRecord::Migration[4.2]
  def up
    unless Audit.column_names.include?("comment")
      add_column :audits, :comment, :string, :limit => 255
      add_column :audits, :auditable_parent_id, :integer
      add_column :audits, :auditable_parent_type, :string, :limit => 255
      add_index :audits, [:auditable_parent_id, :auditable_parent_type], :name => 'auditable_parent_index'
    end
  end

  def down
    remove_column :audits, :comment
    remove_column :audits, :auditable_parent_id
    remove_column :audits, :auditable_parent_type
  end
end
