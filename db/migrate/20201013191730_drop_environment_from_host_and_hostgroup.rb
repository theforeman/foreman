class DropEnvironmentFromHostAndHostgroup < ActiveRecord::Migration[6.0]
  def up
    if ActiveRecord::Base.connection.column_exists?(:hosts, :environment_id)
      remove_foreign_key :hosts, :environments, name: 'hosts_environment_id_fk'
      remove_column :hosts, :environment_id
    end
    if ActiveRecord::Base.connection.column_exists?(:hostgroups, :environment_id)
      remove_foreign_key :hostgroups, :environments, name: 'hostgroups_environment_id_fk'
      remove_column :hostgroups, :environment_id
    end
  end
end
