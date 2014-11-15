class AddLastTaxonomiesToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_organization_id, :integer
    add_column :users, :last_location_id, :integer
  end
end
