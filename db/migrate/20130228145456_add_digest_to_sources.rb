class AddDigestToSources < ActiveRecord::Migration[4.2]
  def up
    remove_index(:sources, :value) if index_exists?(:sources, :value)
    add_column :sources, :digest, :string, :limit => 40
    Source.find_each { |m| m.update_attribute(:digest, Digest::SHA1.hexdigest(m.value)) }
    add_index :sources, :digest
  end

  def down
    remove_index :sources, :digest
    remove_column :sources, :digest
    add_index :sources, :value
  end
end
