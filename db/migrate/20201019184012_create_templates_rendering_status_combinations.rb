class CreateTemplatesRenderingStatusCombinations < ActiveRecord::Migration[6.0]
  def change
    create_table :templates_rendering_status_combinations do |t|
      t.references :host, null: false, foreign_key: true
      t.references :template, null: false, foreign_key: true
      t.integer :status, null: false, default: HostStatus::TemplatesRenderingStatus::PENDING

      t.timestamps
    end

    add_index :templates_rendering_status_combinations, [:host_id, :template_id], unique: true, name: :index_templates_rendering_status_combinations_host_and_templat
  end
end
