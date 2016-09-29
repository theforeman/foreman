class AddComputeAttributesToNics < ActiveRecord::Migration
  def change
    add_column :nics, :compute_attributes, :text
  end
end
