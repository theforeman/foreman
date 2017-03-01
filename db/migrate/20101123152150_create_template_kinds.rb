class CreateTemplateKinds < ActiveRecord::Migration
  def up
    create_table :template_kinds do |t|
      t.string :name, :limit => 255
      t.timestamps null: true
    end
  end

  def down
    drop_table :template_kinds
  end
end
