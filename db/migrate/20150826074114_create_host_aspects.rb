class CreateHostAspects < ActiveRecord::Migration
  def change
    create_table :host_aspects do |t|
      t.integer :host_id
      t.string :aspect_subject
      t.string :execution_model_type
      t.integer :execution_model_id

      t.timestamps
    end
  end
end