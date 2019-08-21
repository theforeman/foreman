class FeatureUniqueName < ActiveRecord::Migration[5.2]
  def up
    add_index :features, :name, :unique => true
  end

  def down
    remove_index :features, :name
  end
end
