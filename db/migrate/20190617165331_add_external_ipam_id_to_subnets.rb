class AddExternalIpamIdToSubnets < ActiveRecord::Migration[5.2]
  def up
    add_column :subnets, :external_ipam_id, :integer
  end

  def down
    remove_column :subnets, :external_ipam_id
  end
end
