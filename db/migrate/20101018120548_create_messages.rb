class CreateMessages < ActiveRecord::Migration[4.2]
  def up
    create_table :messages do |t|
      t.text :value
    end
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql" || ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
      execute "ALTER TABLE messages ENGINE = MYISAM"
      execute "ALTER TABLE messages ADD FULLTEXT (value)"
    else
      add_index :messages, :value
    end
  end

  def down
    remove_index :messages, :value
    drop_table :messages
  end
end
