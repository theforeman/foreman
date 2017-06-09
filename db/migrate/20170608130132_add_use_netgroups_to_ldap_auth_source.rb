class AddUseNetgroupsToLdapAuthSource < ActiveRecord::Migration
  def change
    add_column :auth_sources, :use_netgroups, :boolean, :default => false
  end
end
