class AddProvisionMethodToHosts < ActiveRecord::Migration[4.2]
  def up
    add_column :hosts, :provision_method, :string, :limit => 255
  end

  def down
    remove_column :hosts, :provision_method
  end
end
