class ChangeVlanToInt < ActiveRecord::Migration[5.1]
  def up
    Subnet.unscoped.where(vlanid: "").update_all(vlanid: nil)
    opts = (connection.adapter_name.downcase == 'postgresql') ? {using: 'vlanid::integer'} : {}
    change_column :subnets, :vlanid, :integer, opts
  end

  def down
    change_column :subnets, :vlanid, :string
  end
end
