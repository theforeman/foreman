class CreateConfigTemplates < ActiveRecord::Migration
  def up
    create_table :config_templates do |t|
      t.string :name
      t.text :template
      t.boolean :snippet
      t.references :template_kind
      t.timestamps
    end
  end

  def down
    drop_table :config_templates
  end
end
