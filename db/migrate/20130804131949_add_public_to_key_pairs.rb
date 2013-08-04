class AddPublicToKeyPairs < ActiveRecord::Migration
  def change
    add_column :key_pairs, :public, :string
  end
end
