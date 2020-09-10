class CreateConfigGroupClasses < ActiveRecord::Migration[4.2]
  def change
    create_table :config_group_classes do |t|
      t.integer :puppetclass_id
      t.integer :config_group_id

      t.timestamps null: true
    end
  end
end
