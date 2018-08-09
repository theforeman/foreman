class IndexForeignKeysInParameters < ActiveRecord::Migration[5.1]
  def change
    add_index :parameters, :reference_id
  end
end
