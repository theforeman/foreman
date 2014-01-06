class CreateComputeProfiles < ActiveRecord::Migration
  def change
    create_table :compute_profiles do |t|
      t.string :name

      t.timestamps
    end
  end
end
