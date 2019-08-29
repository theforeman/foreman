class HttpProxyUniqueName < ActiveRecord::Migration[5.2]
  def up
    duplicates = HttpProxy.group(:name).count.select { |key, value| value > 1 }.keys
    unless duplicates.empty?
      HttpProxy.where(name: duplicates).find_each do |proxy|
        say "Http Proxy with duplicate name #{proxy.name} detected. Renaming it as '#{proxy.name}-#{proxy.id}'"
        proxy.update_column(:name, "#{proxy.name}-#{proxy.id}")
      end
    end

    add_index :http_proxies, :name, :unique => true
  end

  def down
    remove_index :http_proxies, :name
  end
end
