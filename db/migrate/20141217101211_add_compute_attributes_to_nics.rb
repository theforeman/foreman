class AddComputeAttributesToNics < ActiveRecord::Migration[4.2]
  def change
    add_column :nics, :compute_attributes, :text
  end
end
