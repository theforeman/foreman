class CreateTemplateKinds < ActiveRecord::Migration
  def self.up
    create_table :template_kinds do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :template_kinds
  end
end
