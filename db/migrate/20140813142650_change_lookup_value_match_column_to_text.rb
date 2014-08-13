class ChangeLookupValueMatchColumnToText < ActiveRecord::Migration
  def up
    remove_index :lookup_values, :match
    change_column :lookup_values, :match, :text

    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql" or ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
      execute "ALTER TABLE lookup_values ENGINE = MYISAM"
      execute "ALTER TABLE lookup_values ADD FULLTEXT (match)"
    else
      add_index :lookup_values, :match
    end
  end

  def down
    remove_index :lookup_values, :match
    change_column :lookup_values, :match, :string
    add_index :lookup_values, :match
  end
end
