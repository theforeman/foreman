class UpdateMediaPathLimit < ActiveRecord::Migration
  def up
    change_column :media, :path, :string, :limit => 255
  end

  def down
    change_column :media, :path, :string, :limit => 100
  end
end
