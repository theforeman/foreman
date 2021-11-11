class HttpProxyUniqueName < ActiveRecord::Migration[5.2]
  def up
    add_index :http_proxies, :name, :unique => true
  end

  def down
    remove_index :http_proxies, :name
  end
end
