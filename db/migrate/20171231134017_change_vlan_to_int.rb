class ChangeVlanToInt < ActiveRecord::Migration[5.1]
  def up
    change_column :subnets, :vlanid, :integer, using: 'vlanid::integer'
  end

  def down
    change_column :subnets, :vlanid, :string
  end
end
