class AddPrimaryInterfaceToHosts < ActiveRecord::Migration[4.2]
  def change
    add_column :hosts, :primary_interface, :string, :limit => 255
  end
end
