class AddDomainToComputeResources < ActiveRecord::Migration
  def change
    add_column :compute_resources, :domain, :string
  end
end
