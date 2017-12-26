class AddConstraintsOnDiscoveryRulesHostgroups < ActiveRecord::Migration
  def change
    # turn off Foreign Key checks
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      ActiveRecord::Migration.execute "SET CONSTRAINTS ALL DEFERRED;"
    elsif ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
      ActiveRecord::Migration.execute "SET FOREIGN_KEY_CHECKS=0;"
    end

    change_column_null :discovery_rules, :hostgroup_id, true

     # if there's some wrong key already, clean the foreign key first
    DiscoveryRule.unscoped.where(["hostgroup_id IS NOT NULL AND hostgroup_id NOT IN (?)", Hostgroup.unscoped.pluck(:id)]).update_all(:hostgroup_id => nil)

    add_foreign_key "discovery_rules", "hostgroups", name: "discovery_rules_hostgroup_id_fk", :column => "hostgroup_id"

    # turn on Foreign Key checks in MySQL only
    if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
      ActiveRecord::Migration.execute "SET FOREIGN_KEY_CHECKS=1;"
    end
  end
end
