class IndexForeignKeysInFilters < ActiveRecord::Migration[5.1]
  def change
    add_index :filters, :role_id
  end
end
