class CreateTemplateCombinations < ActiveRecord::Migration
  def up
    create_table :template_combinations do |t|
      t.references :config_template
      t.references :hostgroup
      t.references :environment

      t.timestamps
    end
  end

  def down
    drop_table :template_combinations
  end
end
