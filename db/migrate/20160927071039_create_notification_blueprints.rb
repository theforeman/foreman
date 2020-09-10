class CreateNotificationBlueprints < ActiveRecord::Migration[4.2]
  def change
    create_table :notification_blueprints do |t|
      t.string :group, index: true
      t.string :level
      t.string :message
      t.text :name
      t.integer :expires_in
      t.timestamps null: false
      t.references :subject, polymorphic: true
    end
  end
end
