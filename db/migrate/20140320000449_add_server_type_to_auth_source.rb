class AddServerTypeToAuthSource < ActiveRecord::Migration[4.2]
  def change
    add_column :auth_sources, :server_type, :string, :default => 'posix', :limit => 255
  end
end
