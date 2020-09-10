class AddDefaultOrganizationIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :default_organization_id, :integer
  end
end
