class AddDigestToSources < ActiveRecord::Migration[4.2]
  def up
    if ["mysql", "mysql2"].include? ActiveRecord::Base.connection.instance_values["config"][:adapter]
      execute "DROP INDEX value ON sources" if index_exists?(:sources, :value, :name => 'value')
    else
      remove_index(:sources, :value) if index_exists?(:sources, :value)
    end
    add_column :sources, :digest, :string, :limit => 40
    Source.find_each {|m| m.update_attribute(:digest, Digest::SHA1.hexdigest(m.value)) }
    add_index :sources, :digest
  end

  def down
    remove_index :sources, :digest
    remove_column :sources, :digest
    if ["mysql", "mysql2"].include? ActiveRecord::Base.connection.instance_values["config"][:adapter]
      execute "ALTER TABLE sources ADD FULLTEXT (value)"
    else
      add_index :sources, :value
    end
  end
end
