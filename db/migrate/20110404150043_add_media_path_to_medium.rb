class AddMediaPathToMedium < ActiveRecord::Migration[4.2]
  def up
    add_column :media, :media_path,  :string, :limit => 128
    add_column :media, :config_path, :string, :limit => 128
    add_column :media, :image_path,  :string, :limit => 128
  end

  def down
    remove_column :media, :config_path
    remove_column :media, :media_path
    remove_column :media, :image_path
  end
end
