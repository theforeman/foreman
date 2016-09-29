class AddProxyToDomain < ActiveRecord::Migration
  def up
    add_column :domains, :dns_id, :integer
    remove_column :domains, :dnsserver
    remove_column :domains, :gateway
  end

  def down
    remove_column :domains, :dns_id
  end
end
