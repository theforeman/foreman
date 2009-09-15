class ChangeReportFieldTypeToText < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql"
      execute "ALTER TABLE reports MODIFY log text;"
    end
  end

  def self.down
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql"
      change_column :reports, :log, :text, :limit => 50.kilobytes, :null => false
    end
  end
end
