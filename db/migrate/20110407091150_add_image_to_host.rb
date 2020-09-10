class AddImageToHost < ActiveRecord::Migration[4.2]
  def up
    add_column :hosts, :use_image, :boolean
    add_column :hosts, :image_file, :string, :limit => 128
    add_column :hostgroups, :use_image, :boolean
    add_column :hostgroups, :image_file, :string, :limit => 128
  end

  def down
    remove_column :hostgroups, :image_file
    remove_column :hostgroups, :use_image
    remove_column :hosts, :image_file
    remove_column :hosts, :use_image
  end
end
