class CreateMailNotifications < ActiveRecord::Migration
  def change
    create_table :mail_notifications do |t|
      t.string :name
      t.string :description
      t.string :mailer
      t.string :method
      t.boolean :subscriptable, :default => true
      t.string :default_interval

      t.timestamps
    end
  end
end
