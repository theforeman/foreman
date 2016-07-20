# To suport "Edit my compute resource" security access control we need
# a mechanism to associate a user with some compute resources
class AddUserComputeResources < ActiveRecord::Migration[4.2]
  def up
    create_table :user_compute_resources, :id => false do |t|
      t.references :user
      t.references :compute_resource
    end
  end

  def down
    drop_table :user_compute_resources
  end
end
