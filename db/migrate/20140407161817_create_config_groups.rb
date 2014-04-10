class CreateConfigGroups < ActiveRecord::Migration
  def change
    create_table :config_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end


