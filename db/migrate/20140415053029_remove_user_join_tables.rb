class RemoveUserJoinTables < ActiveRecord::Migration[4.2]
  def up
    if table_exists? :user_compute_resources
      remove_foreign_key 'user_compute_resources', 'users'
      remove_foreign_key 'user_compute_resources', 'compute_resources'
      drop_table :user_compute_resources
    end
    if table_exists? :user_notices
      remove_foreign_key 'user_notices', 'notices'
      remove_foreign_key 'user_notices', 'users'
      drop_table :user_notices
    end
    if table_exists? :user_facts
      remove_foreign_key 'user_facts', 'fact_names'
      remove_foreign_key 'user_facts', 'users'
      drop_table :user_facts
    end
    if table_exists? :user_hostgroups
      remove_foreign_key 'user_hostgroups', 'hostgroups'
      remove_foreign_key 'user_hostgroups', 'users'
      drop_table :user_hostgroups
    end
    if table_exists? :user_domains
      remove_foreign_key 'user_domains', 'domains'
      remove_foreign_key 'user_domains', 'users'
      drop_table :user_domains
    end

    drop_table :notices if table_exists? :notices
  end
end
