class ChangeMysqlReportsColumn < ActiveRecord::Migration[4.2]
  def up
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql" || ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
      execute "ALTER TABLE reports MODIFY log mediumtext;"
    end
  end

  def down
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql" || ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
      execute "ALTER TABLE reports MODIFY log text;"
    end
  end
end
