class AddComputeProfileToHostgroup < ActiveRecord::Migration[4.2]
  def change
    add_column :hostgroups, :compute_profile_id, :integer
    add_column :hosts, :compute_profile_id, :integer

    add_index :hostgroups, :compute_profile_id
    add_index :hosts, :compute_profile_id

    add_foreign_key "hostgroups", "compute_profiles", :name => "hostgroups_compute_profile_id_fk"
    add_foreign_key "hosts", "compute_profiles", :name => "hosts_compute_profile_id_fk"
  end
end
