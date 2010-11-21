class CreateOperatingsystemsConfigTemplates < ActiveRecord::Migration
  def self.up
    create_table :config_templates_operatingsystems, :id => false do |t|
      t.references :config_template, :null => false
      t.references :operatingsystem, :null => false
    end
  end

  def self.down
    drop_table :config_templates_operatingsystems
  end
end
