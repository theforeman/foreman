class AddOverrideFlagToFilter < ActiveRecord::Migration[4.2]
  def up
    add_column :filters, :override, :boolean, :default => false, :null => false
  end

  def down
    remove_column :filters, :override
  end
end
