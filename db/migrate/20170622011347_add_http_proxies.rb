class AddHttpProxies < ActiveRecord::Migration[4.2]
  def change
    create_table :http_proxies do |t|
      t.string :name, :null => false
      t.string :url, :null => false
      t.string :username
      t.string :password
    end

    add_reference :compute_resources, :http_proxy
  end
end
