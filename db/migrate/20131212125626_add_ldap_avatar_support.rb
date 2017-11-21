class AddLdapAvatarSupport < ActiveRecord::Migration[4.2]
  def change
    add_column :auth_sources, :attr_photo, :string, :limit => 255
    add_column :users, :avatar_hash, :string, :limit => 128
  end

  def down
    remove_column :users, :avatar_hash
    remove_column :auth_sources, :attr_photo
  end
end
