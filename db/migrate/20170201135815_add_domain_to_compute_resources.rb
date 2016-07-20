class AddDomainToComputeResources < ActiveRecord::Migration[4.2]
  def change
    add_column :compute_resources, :domain, :string
  end
end
