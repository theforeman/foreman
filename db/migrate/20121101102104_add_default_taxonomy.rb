class AddDefaultTaxonomy < ActiveRecord::Migration
  def self.up
    User.as :admin do
      org_id = Organization.create(:name=>"Default").try(:id)
      location_id = Location.create(:name=>"Default").try(:id)
      execute  "UPDATE hosts SET organization_id=#{org_id} WHERE organization_id IS NULL" unless org_id.nil?
      execute  "UPDATE hosts SET location_id=#{location_id} WHERE location_id IS NULL"    unless location_id.nil?
    end
  end

  def self.down
  end
end
