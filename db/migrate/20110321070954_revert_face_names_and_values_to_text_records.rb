class RevertFaceNamesAndValuesToTextRecords < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql"
      index = ActiveRecord::Base.connection.indexes("fact_names").map(&:columns).flatten.include?("name") rescue false

      remove_index :fact_names, :name if index

      execute "ALTER TABLE fact_names MODIFY name text COLLATE utf8_bin NOT NULL;"
      execute "ALTER TABLE fact_values MODIFY value text COLLATE utf8_bin NOT NULL;"
      execute "CREATE INDEX `index_fact_names_on_name` ON `fact_names` (name(255))" if index
    end
  end

  def self.down
    if ActiveRecord::Base.connection.instance_values["config"][:adapter] == "mysql"
      execute %{ALTER TABLE fact_names MODIFY name varchar(255) COLLATE utf8_bin NOT NULL}
      execute %{ALTER TABLE fact_values MODIFY value varchar(255) COLLATE utf8_bin NOT NULL}
    end
  end
end
