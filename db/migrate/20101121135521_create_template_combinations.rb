class CreateTemplateCombinations < ActiveRecord::Migration[4.2]
  def up
    create_table :template_combinations do |t|
      t.references :config_template
      t.references :hostgroup

      t.timestamps null: true
    end
  end

  def down
    drop_table :template_combinations
  end
end
