class AddIndexToDomainName < ActiveRecord::Migration
  def up
    case ActiveRecord::Base.connection.instance_values["config"][:adapter]
    when "postgresql"
      execute 'CREATE UNIQUE INDEX domain_name_index ON domains (lower(name))'
    when "sqlite3"
      execute 'CREATE UNIQUE INDEX domain_name_index ON domains (name collate nocase)'
    else
      add_index :domains, :name, :name => 'domain_name_index', :unique => true
    end
  end

  def down
    remove_index! :domains, 'domain_name_index'
  end
end
