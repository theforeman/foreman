class AddExpiredLogsToSmartProxy < ActiveRecord::Migration
  def change
    add_column :smart_proxies, :expired_logs, :string, :default => '0', :limit => 255
  end
end
