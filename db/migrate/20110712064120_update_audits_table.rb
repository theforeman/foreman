class UpdateAuditsTable < ActiveRecord::Migration
  def up
    unless Audit.column_names.include?("comment")
      add_column :audits, :comment, :string
      add_column :audits, :auditable_parent_id, :integer
      add_column :audits, :auditable_parent_type, :string
      add_index :audits, [:auditable_parent_id, :auditable_parent_type], :name => 'auditable_parent_index'
    end
  end

  def down
    remove_column :audits, :comment
    remove_column :audits, :auditable_parent_id
    remove_column :audits, :auditable_parent_type
  end
end
