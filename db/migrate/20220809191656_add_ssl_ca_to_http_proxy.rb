class AddSslCaToHttpProxy < ActiveRecord::Migration[6.1]
  def change
    add_column :http_proxies, :cacert, :text
  end
end
