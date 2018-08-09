class IndexForeignKeysInArchitecturesOperatingsystems < ActiveRecord::Migration[5.1]
  def change
    add_index :architectures_operatingsystems, :architecture_id
    add_index :architectures_operatingsystems, :operatingsystem_id
  end
end
