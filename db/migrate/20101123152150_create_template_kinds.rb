class CreateTemplateKinds < ActiveRecord::Migration
  def up
    create_table :template_kinds do |t|
      t.string :name
      t.timestamps
    end
  end

  def down
    drop_table :template_kinds
  end
end
