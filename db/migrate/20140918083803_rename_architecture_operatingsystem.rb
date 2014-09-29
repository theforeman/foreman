class RenameArchitectureOperatingsystem < ActiveRecord::Migration
  def change
    rename_table :architectures_operatingsystems, :architecture_operatingsystems
    add_column :architecture_operatingsystems, :id, :primary_key
  end
end
