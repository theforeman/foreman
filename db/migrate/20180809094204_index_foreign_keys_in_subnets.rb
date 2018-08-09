class IndexForeignKeysInSubnets < ActiveRecord::Migration[5.1]
  def change
    add_index :subnets, :dhcp_id
    add_index :subnets, :dns_id
    add_index :subnets, :template_id
    add_index :subnets, :tftp_id
  end
end
