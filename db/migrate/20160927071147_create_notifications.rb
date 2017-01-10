class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :notification_type, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true
      t.references :subject, polymorphic: true
      t.timestamp  :expired_at

      t.timestamps null: false
    end
  end
end
