class AddStiToSettings < ActiveRecord::Migration[4.2]
  def up
    add_index :settings, :category
  end

  def down
    remove_index :settings, :category
  end
end
