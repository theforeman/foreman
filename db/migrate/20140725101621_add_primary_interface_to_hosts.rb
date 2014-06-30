class AddPrimaryInterfaceToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :primary_interface, :string
  end
end
