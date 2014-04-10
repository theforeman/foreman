class CreateConfigGroupClasses < ActiveRecord::Migration
  def change
    create_table :config_group_classes do |t|
      t.integer :puppetclass_id
      t.integer :config_group_id

      t.timestamps
    end
  end
end
