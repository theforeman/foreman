class CreateSources < ActiveRecord::Migration
  def up
    create_table :sources do |t|
      t.text :value
    end
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql" or ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
      execute "ALTER TABLE sources ENGINE = MYISAM"
      execute "ALTER TABLE sources ADD FULLTEXT (value)"
    else
      add_index :sources, :value
    end
  end

  def down
    remove_index :sources, :value
    drop_table :sources
  end
end
