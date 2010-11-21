class CreateTemplateCombinations < ActiveRecord::Migration
  def self.up
    create_table :template_combinations do |t|
      t.references :config_template
      t.references :hostgroup
      t.references :environment

      t.timestamps
    end
  end

  def self.down
    drop_table :template_combinations
  end
end
