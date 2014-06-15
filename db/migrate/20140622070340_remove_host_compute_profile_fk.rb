class RemoveHostComputeProfileFk < ActiveRecord::Migration
  def up
    remove_foreign_key :hosts, :compute_profile
  end

  def down
    add_foreign_key :hosts, :compute_profiles, :name => "hosts_compute_profile_id_fk"
  end
end
