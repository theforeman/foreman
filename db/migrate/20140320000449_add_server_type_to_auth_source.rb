class AddServerTypeToAuthSource < ActiveRecord::Migration
  def change
    add_column :auth_sources, :server_type, :string, :default => 'posix', :limit => 255
  end
end
