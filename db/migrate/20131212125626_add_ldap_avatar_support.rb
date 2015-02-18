class AddLdapAvatarSupport < ActiveRecord::Migration
  def change
    add_column :auth_sources, :attr_photo, :string
    add_column :users, :avatar_hash, :string, :limit => 128
  end

  def down
    remove_column :users, :avatar_hash
    remove_column :auth_sources, :attr_photo
  end
end
