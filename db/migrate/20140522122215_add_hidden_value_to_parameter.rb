class AddHiddenValueToParameter < ActiveRecord::Migration
  def change
    add_column :parameters, :hidden_value, :boolean, :default => false
  end
end
