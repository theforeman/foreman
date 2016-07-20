class AddLocaleToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :locale, :string, :limit => 5, :null => true
  end
end
