class CreateComputeProfiles < ActiveRecord::Migration[4.2]
  def change
    create_table :compute_profiles do |t|
      t.string :name, :limit => 255

      t.timestamps null: true
    end
  end
end
