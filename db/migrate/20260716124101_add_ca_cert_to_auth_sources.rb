class AddCACertToAuthSources < ActiveRecord::Migration[7.0]
  def change
    add_column :auth_sources, :cacert, :text
  end
end
