class CreateConfigTemplates < ActiveRecord::Migration[4.2]
  def up
    create_table :config_templates do |t|
      t.string :name, :limit => 255
      t.text :template
      t.boolean :snippet
      t.references :template_kind
      t.timestamps null: true
    end
  end

  def down
    drop_table :config_templates
  end
end
