class AddDigestToMessages < ActiveRecord::Migration[4.2]
  def up
    remove_index(:messages, :value) if index_exists?(:messages, :value)
    add_column :messages, :digest, :string, :limit => 40
    add_index :messages, :digest
  end

  def down
    remove_index :messages, :digest
    remove_column :messages, :digest
    add_index :messages, :value
  end
end
