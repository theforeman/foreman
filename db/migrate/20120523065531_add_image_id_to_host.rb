class AddImageIdToHost < ActiveRecord::Migration
  def self.up
    add_column :hosts, :image_id, :integer
  end

  def self.down
    remove_column :hosts, :image_id
  end
end
