class AddExternalIpamIdToSubnets < ActiveRecord::Migration[5.2]
  def up
    add_column :subnets, :externalipam_id, :integer
    add_column :subnets, :externalipam_group, :text
    add_index(:subnets, :externalipam_id)
  end

  def down
    remove_column :subnets, :externalipam_id
    remove_column :subnets, :externalipam_group
    remove_index(:subnets, :externalipam_id)
  end
end
