class RemoveUnusedFieldsFromHosts < ActiveRecord::Migration[4.2]
  def up
    remove_index :hosts, :source_file_id
    remove_columns :hosts, :last_freshcheck, :serial, :source_file_id
  end

  def down
    add_column :hosts, :last_freshcheck, :datetime
    add_column :hosts, :serial, :string, :limit => 255
    add_column :hosts, :source_file_id, :integer
    add_index :hosts, :source_file_id
  end
end
