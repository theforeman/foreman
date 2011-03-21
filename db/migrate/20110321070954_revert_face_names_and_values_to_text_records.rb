class RevertFaceNamesAndValuesToTextRecords < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql"
      execute "ALTER TABLE fact_values MODIFY value text COLLATE utf8_bin NOT NULL;"
    end
  end

  def self.down
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql"
      execute %{ALTER TABLE fact_values MODIFY value varchar(255) COLLATE utf8_bin NOT NULL}
    end
  end
end
