class CreateOperatingsystemsConfigTemplates < ActiveRecord::Migration[4.2]
  def up
    create_table :config_templates_operatingsystems, :id => false do |t|
      t.references :config_template, :null => false
      t.references :operatingsystem, :null => false
    end
  end

  def down
    drop_table :config_templates_operatingsystems
  end
end
