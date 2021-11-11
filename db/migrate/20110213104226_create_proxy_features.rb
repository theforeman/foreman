class CreateProxyFeatures < ActiveRecord::Migration[4.2]
  def up
    # Create the tables
    create_table :features do |t|
      t.string :name, :limit => 16
      t.timestamps null: true
    end

    create_table :features_smart_proxies, :id => false do |t|
      t.references :smart_proxy
      t.references :feature
    end
  end

  def down
    drop_table :features
    drop_table :features_smart_proxies
  end
end
