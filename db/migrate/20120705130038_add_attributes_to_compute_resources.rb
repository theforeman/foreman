class AddAttributesToComputeResources < ActiveRecord::Migration[4.2]
  def up
    add_column :compute_resources, :attrs, :text unless column_exists? :compute_resources, :attrs
  end

  def down
    remove_column :compute_resources, :attrs if column_exists? :compute_resources, :attrs
  end
end
