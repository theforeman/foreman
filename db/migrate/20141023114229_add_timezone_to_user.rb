class AddTimezoneToUser < ActiveRecord::Migration
  def change
    add_column :users, :timezone, :string, :limit => 255
  end
end
