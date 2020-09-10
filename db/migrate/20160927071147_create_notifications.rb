class CreateNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :notifications do |t|
      t.references :notification_blueprint, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true
      t.string :audience
      t.timestamp  :expired_at
      t.timestamps null: false
    end
  end
end
