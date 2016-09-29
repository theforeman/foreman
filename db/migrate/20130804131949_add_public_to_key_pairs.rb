class AddPublicToKeyPairs < ActiveRecord::Migration
  def change
    add_column :key_pairs, :public, :text
  end
end
