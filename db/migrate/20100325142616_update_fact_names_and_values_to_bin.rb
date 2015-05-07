class UpdateFactNamesAndValuesToBin < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql" or ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
      execute %{ALTER TABLE fact_names MODIFY name varchar(255) COLLATE utf8_bin NOT NULL}
      execute %{ALTER TABLE fact_values MODIFY value varchar(255) COLLATE utf8_bin NOT NULL}
    end
  end

  def down
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql" or ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
      execute %{ALTER TABLE fact_names MODIFY name varchar(255)}
      execute %{ALTER TABLE fact_values MODIFY value varchar(255)}
    end
  end
end
