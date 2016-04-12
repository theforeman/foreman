class AddLockToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :locked_until, :integer
  end
end
