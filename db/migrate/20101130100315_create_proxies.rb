class CreateProxies < ActiveRecord::Migration
  def up
    create_table :smart_proxies do |t|
      t.string :name, :limit => 255
      t.string :url, :limit => 255
      t.timestamps null: true
    end
  end

  def down
    drop_table :smart_proxies
  end
end
