class AddUuidToSmartProxy < ActiveRecord::Migration[6.0]
  def change
    add_column :smart_proxies, :uuid, :string
  end
end
