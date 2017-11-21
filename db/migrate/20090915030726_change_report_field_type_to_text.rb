class ChangeReportFieldTypeToText < ActiveRecord::Migration[4.2]
  def up
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql" || ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
      execute "ALTER TABLE reports MODIFY log text;"
    end
  end

  def down
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql" || ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql2"
      change_column :reports, :log, :text, :limit => 50.kilobytes, :null => false
    end
  end
end
