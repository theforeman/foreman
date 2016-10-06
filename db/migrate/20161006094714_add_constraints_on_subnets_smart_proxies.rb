class AddConstraintsOnSubnetsSmartProxies < ActiveRecord::Migration
  def change
     # turn off Foreign Key checks
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      ActiveRecord::Migration.execute "SET CONSTRAINTS ALL DEFERRED;"
    elsif ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
      ActiveRecord::Migration.execute "SET FOREIGN_KEY_CHECKS=0;"
    end

     add_foreign_key "subnets", "smart_proxies", :name => "subnets_discovery_id_fk", :column => "discovery_id"
    
     # turn on Foreign Key checks in MySQL only
    if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
      ActiveRecord::Migration.execute "SET FOREIGN_KEY_CHECKS=1;"
    end
  end
end
