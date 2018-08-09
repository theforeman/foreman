class IndexForeignKeysInTemplateCombinations < ActiveRecord::Migration[5.1]
  def change
    add_index :template_combinations, :environment_id
    add_index :template_combinations, :hostgroup_id
    add_index :template_combinations, :provisioning_template_id
  end
end
