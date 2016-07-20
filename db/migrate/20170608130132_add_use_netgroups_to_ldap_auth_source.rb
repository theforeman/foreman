class AddUseNetgroupsToLdapAuthSource < ActiveRecord::Migration[4.2]
  def change
    add_column :auth_sources, :use_netgroups, :boolean, :default => false
  end
end
