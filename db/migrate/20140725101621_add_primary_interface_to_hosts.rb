class AddPrimaryInterfaceToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :primary_interface, :string, :limit => 255
  end
end
