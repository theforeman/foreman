class CreateNotificationTypes < ActiveRecord::Migration
  def change
    create_table :notification_types do |t|
      t.string :name, index: true, unique: true
      t.string :level
      t.text :message
      t.string :audience
      t.integer :expires_in

      t.timestamps null: false
    end
  end
end
