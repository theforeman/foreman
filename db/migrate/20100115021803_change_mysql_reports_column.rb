class ChangeMysqlReportsColumn < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql" or ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
      execute "ALTER TABLE reports MODIFY log mediumtext;"
    end
  end

  def down
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql" or ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
      execute "ALTER TABLE reports MODIFY log text;"
    end
  end
end

