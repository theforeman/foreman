class ChangeSubnetVlanidSize < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up do
        change_column :subnets, :vlanid, :integer, limit: 4
      end
      dir.down do
        change_column :subnets, :vlanid, :string, limit: 10
      end
    end
  end
end
