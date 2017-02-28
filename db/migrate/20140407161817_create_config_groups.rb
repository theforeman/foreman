class CreateConfigGroups < ActiveRecord::Migration
  def change
    create_table :config_groups do |t|
      t.string :name, :limit => 255

      t.timestamps null: true
    end
  end
end
