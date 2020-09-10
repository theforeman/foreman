class ChangeDigestsLimit < ActiveRecord::Migration[5.1]
  def up
    change_column :messages, :digest, :string, :limit => 40
    change_column :sources, :digest, :string, :limit => 40
  end

  def down
    change_column :messages, :digest, :string, :limit => 255
    change_column :sources, :digest, :string, :limit => 255
  end
end
