class CreateNotificationRecipients < ActiveRecord::Migration[4.2]
  def change
    create_table :notification_recipients do |t|
      t.references :notification, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.boolean :seen, default: false, index: true

      t.timestamps null: false
    end
  end
end
