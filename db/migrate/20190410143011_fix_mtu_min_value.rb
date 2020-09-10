class FixMtuMinValue < ActiveRecord::Migration[5.2]
  def up
    Subnet.where("mtu < 68").update_all(mtu: 68)
  end
end
