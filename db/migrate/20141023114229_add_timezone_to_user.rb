class AddTimezoneToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :timezone, :string, :limit => 255
  end
end
