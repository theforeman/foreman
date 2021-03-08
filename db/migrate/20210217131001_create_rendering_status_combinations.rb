class CreateRenderingStatusCombinations < ActiveRecord::Migration[6.0]
  def change
    create_table :rendering_status_combinations do |t|
      t.references :host, null: false, foreign_key: true
      t.references :template, null: false, foreign_key: true
      t.integer :safemode_status
      t.integer :unsafemode_status

      t.timestamps
    end
  end
end
