class AddOsFamilyToMedia < ActiveRecord::Migration[4.2]
  def up
    add_column :media, :os_family, :string, :limit => 255
  end

  def down
    remove_column :media, :os_family
  end
end
