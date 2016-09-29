class CreateProxyFeatures < ActiveRecord::Migration
  class Feature < ActiveRecord::Base; end

  def up
    # Create the tables
    create_table :features do |t|
      t.string :name, :limit => 16
      t.timestamps
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
