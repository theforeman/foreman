class UpdateMediaPathLimit < ActiveRecord::Migration
  def self.up
    change_column :media, :path, :string, :limit => 255
  end

  def self.down
  end
end
