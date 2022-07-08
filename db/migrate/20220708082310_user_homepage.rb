class UserHomepage < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :homepage, :string, default: '/'
  end
end
