class CreateMailNotifications < ActiveRecord::Migration
  def change
    create_table :mail_notifications do |t|
      t.string :name, :limit => 255
      t.string :description, :limit => 255
      t.string :mailer, :limit => 255
      t.string :method, :limit => 255
      t.boolean :subscriptable, :default => true
      t.string :default_interval, :limit => 255

      t.timestamps
    end
  end
end
