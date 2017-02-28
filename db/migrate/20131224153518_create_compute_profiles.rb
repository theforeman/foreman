class CreateComputeProfiles < ActiveRecord::Migration
  def change
    create_table :compute_profiles do |t|
      t.string :name, :limit => 255

      t.timestamps null: true
    end
  end
end
