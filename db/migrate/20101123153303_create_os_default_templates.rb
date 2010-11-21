class CreateOsDefaultTemplates < ActiveRecord::Migration
  def self.up
    create_table :os_default_templates do |t|
      t.references :config_template
      t.references :template_kind
      t.references :operatingsystem

      t.timestamps
    end
  end

  def self.down
    drop_table :os_default_templates
  end
end
