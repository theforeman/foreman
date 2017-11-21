class CreateConfigGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :config_groups do |t|
      t.string :name, :limit => 255

      t.timestamps null: true
    end
  end
end
