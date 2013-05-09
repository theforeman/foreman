class AddLocaleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :locale, :string, :limit => 5, :null => true
  end
end
