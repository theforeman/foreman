class AddHiddenValueToParameter < ActiveRecord::Migration[4.2]
  def change
    add_column :parameters, :hidden_value, :boolean, :default => false
  end
end
