class ChangeComputeResourcePasswordLength < ActiveRecord::Migration[5.2]
  def change
    change_column :compute_resources, :password, :text, :limit => nil
  end
end
