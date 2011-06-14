class AddMediaPathToMedium < ActiveRecord::Migration
  def self.up
    add_column :media, :media_path,  :text, :limit => 128
    add_column :media, :config_path, :text, :limit => 128
    add_column :media, :image_path,  :text, :limit => 128
  end

  def self.down
    remove_column :media, :config_path
    remove_column :media, :media_path
    remove_column :media, :image_path
  end
end
