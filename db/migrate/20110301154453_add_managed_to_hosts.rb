class AddManagedToHosts < ActiveRecord::Migration
  def up
    add_column :hosts, :managed, :boolean

    Host.reset_column_information

    for host in Host.unscoped.all
      host.update_attribute :managed, !!host.operatingsystem_id and !!host.architecture_id and (!!host.ptable_id or not host.disk.empty?)
    end
  end

  def down
    remove_column :hosts, :managed
  end
end
