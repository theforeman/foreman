class ChangeDefaultValueForMailEnabledToUser < ActiveRecord::Migration[6.1]
  def change
    change_column_default :users, :mail_enabled, from: true, to: false
  end
end
