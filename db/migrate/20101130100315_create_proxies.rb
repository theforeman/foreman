class CreateProxies < ActiveRecord::Migration
  def up
    create_table :smart_proxies do |t|
      t.string :name
      t.string :url
      t.timestamps
    end
  end

  def down
    drop_table :smart_proxies
  end
end
